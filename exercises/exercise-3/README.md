# Exercise 3: Monitoring and Observability

Your guestbook is deployed and serving traffic — but if something breaks at 2 AM, how would you know? In this exercise we'll add structured logging, a CloudWatch dashboard, and alarms so the application tells *you* when something is wrong instead of waiting for a user to complain.

## Key objectives

* Replace default console output with structured JSON logging
* Understand log levels and when to use each one
* Ship logs to CloudWatch and query them with Logs Insights
* Build a CloudWatch dashboard for key application metrics
* Define alarms that notify you when something needs attention

## Requirements

### Structured logging

Out of the box, Next.js writes unstructured text to stdout. That's fine for local development, but in production you need logs that are machine-parseable so CloudWatch Logs Insights (and any future log aggregator) can filter and query them.

Switch your application to a structured JSON logger. **Pino** is the idiomatic choice for Next.js — it's fast, outputs JSON by default, and has first-class Next.js support. Winston is another popular option. Pick one and wire it up so that every log line your application emits is a valid JSON object.

Your logger should include at minimum:

* `level` — the severity (see below)
* `message` — a human-readable description
* Any additional context that would help you debug in production (e.g., request path, user action, record count)

#### Log levels

Use these standard levels and understand when each is appropriate:

| Level   | When to use |
|---------|------------|
| `error` | Something failed and needs attention — a DynamoDB write that threw, an unhandled exception, a downstream service timeout. |
| `warn`  | Something unexpected happened but the application recovered — a retry succeeded, a deprecated code path was hit, a request took longer than expected. |
| `info`  | Normal operational events you'd want to see in production — application started, a guestbook entry was saved, a cleanup ran. |
| `debug` | Detailed diagnostic information useful during development — full request/response payloads, intermediate calculation steps. Should typically be suppressed in production via a `LOG_LEVEL` environment variable. |

Add a `LOG_LEVEL` environment variable to your application that controls the minimum severity emitted. Set it to `info` in your ECS task definition and `debug` in your local `.env`.

Instrument your application so that it produces logs at **every level**. You should have at least:

* An `info` log when a guestbook entry is saved
* An `info` log when old records are cleaned up, including how many were deleted
* A `warn` log when a request takes longer than a threshold you define
* An `error` log when a DynamoDB operation fails (wrap your SDK calls in try/catch if you haven't already)
* `debug` logs showing the raw input and DynamoDB parameters for each operation

These samples will be useful when you test your Logs Insights queries.

### CloudWatch Log Group

Your ECS task definition from exercise 2 should already be sending logs to CloudWatch. Update the Terraform to ensure:

* The log group has a **14-day retention policy**. Logs cost money to store. In a learning environment 14 days is plenty; in production you'd choose a retention period based on compliance and debugging needs.
* The log group name follows a clear convention (e.g., `/ecs/guestbook`).

### CloudWatch Logs Insights

Define a **CloudWatch Logs Insights query** in Terraform using the `aws_cloudwatch_query_definition` resource. This makes the query available to anyone on the team from the CloudWatch console — no tribal knowledge required.

Create a saved query that filters logs by level. For example, a query that returns the 100 most recent `error` and `warn` logs:

```
fields @timestamp, level, message
| filter level in ["error", "warn"]
| sort @timestamp desc
| limit 100
```

Explore the Logs Insights syntax — `stats`, `filter`, `parse`, and `sort` are the building blocks. The point is not to memorize every function but to know the tool exists and be able to write a query when you need one.

### CloudWatch Dashboard

Create a CloudWatch dashboard in Terraform using the `aws_cloudwatch_dashboard` resource. The dashboard should give you a single-pane view of application health.

Include **at least** these two widgets as a starting point:

* **ECS CPU and Memory utilization** — are your tasks running hot or starved?
* **ALB request count and HTTP 5xx count** — is traffic flowing and are errors spiking?

Beyond these two, think about what *you* would want to see if you were paged at 2 AM and add at least one more widget. Some ideas: target response time, healthy host count, DynamoDB consumed read/write capacity. The goal is to practice building dashboards, not to build the perfect one on the first try.

Dashboard JSON can be verbose. Consider using `jsonencode()` in Terraform to build the dashboard body programmatically rather than maintaining a raw JSON string.

### Alarms

Define CloudWatch alarms in Terraform that notify you via email when something needs attention.

#### SNS Topic

Create an **SNS topic** and an **email subscription** in Terraform. When you apply, AWS will send a confirmation email to the address you provide — you must click the link to activate the subscription. This is a one-time manual step.

The email address should be passed in as a Terraform variable, not hardcoded.

#### Alarm definitions

Create at least two alarms:

* **High 5xx rate** — triggers when the ALB returns more than a threshold of HTTP 5xx responses in a 5-minute period. This catches application errors and crashes.
* **High CPU utilization** — triggers when ECS task CPU exceeds a threshold (e.g., 80%) for a sustained period. This catches runaway processes and capacity problems before they impact users.

Each alarm should send to the SNS topic you created. Think about the evaluation period, datapoints to alarm, and the difference between `Average`, `Sum`, and `Maximum` statistics — choosing the wrong statistic is one of the most common alarm mistakes.

After applying, intentionally trigger an alarm to verify the full pipeline works. For example, you could deploy a temporary code change that returns 500s on a specific endpoint and hit it with `curl` in a loop.

## Key Takeaways

* **Structured logging**: JSON logs make your application observable. Unstructured text is fine for reading in a terminal but impossible to query at scale.
* **Log levels are a contract**: They tell the on-call engineer what is noise (`debug`), what is normal (`info`), what is concerning (`warn`), and what is broken (`error`). Use them consistently.
* **Dashboards are for humans**: A good dashboard answers "is everything okay?" in under five seconds. Build them before you need them.
* **Alarms close the loop**: Logs and dashboards are useless if nobody is watching. Alarms push notifications to you so problems are caught even when you're not looking.
* **Infrastructure as Code for observability**: Defining dashboards, alarms, and saved queries in Terraform means they're version-controlled, reviewable, and reproducible — just like the infrastructure they monitor.

## Next steps

In the next exercise, we'll automate the deployment pipeline with GitHub Actions so that pushing to `main` triggers a build, test, and deploy cycle without manual intervention.

## Questions you should be able to answer

After completing this, you should be able to answer these questions:

### Logging

* What is structured logging and why is it better than `console.log` in production?
* What is the purpose of log levels? Who benefits from them and when?
* If you set `LOG_LEVEL=warn`, which log levels will be emitted? Which will be suppressed?
* Why should `debug` logs be turned off in production?
* What fields should every structured log line contain at minimum?

### CloudWatch Logs

* What is a CloudWatch Log Group? What is a Log Stream?
* Why set a retention policy on a log group?
* What is the cost implication of storing logs indefinitely?
* Write a Logs Insights query that counts the number of errors per hour over the last 24 hours.

### Dashboards

* What makes a good operational dashboard?
* What is the difference between a metric and a log?
* Name three CloudWatch metrics that ECS publishes automatically without any application changes.
* Why use `jsonencode()` instead of raw JSON strings in Terraform?

### Alarms

* What is the difference between an alarm in `ALARM`, `OK`, and `INSUFFICIENT_DATA` state?
* What is an evaluation period? What are "datapoints to alarm"?
* Explain the difference between the `Average`, `Sum`, and `Maximum` statistics. When would you choose each?
* What happens if nobody confirms the SNS email subscription?
* Why should the notification email address be a Terraform variable instead of hardcoded?

### Bigger Picture

* You've now built logging, dashboards, and alarms. Which of these three would you set up first on a brand-new production service, and why?
* What is the difference between monitoring and observability?
* What other pillars of observability exist beyond logs and metrics? (Hint: traces.)
