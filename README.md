# ops-101

Exercises that serve as a crash course on DevOps.

Each exercise builds on the one before it. You build a small guestbook web app. Then you deploy it to AWS and add monitoring. You use an AI assistant (Cursor or Claude Code) for the work, and you must understand every line it writes.

## What it covers

1. **Exercise 1: Guestbook app in local development.** Build a Next.js app that writes to DynamoDB. Run DynamoDB locally with Docker. Add linting and tests with vitest.
2. **Exercise 2: Deploy the Guestbook.** Package the app as a Docker image. Use Terraform to create an ECR repository, an ECS Fargate service, an ALB, IAM roles, and security groups. Deploy with a shell script.
3. **Exercise 3: Monitoring and Observability.** Add structured JSON logging. Use Terraform to create a log group with 14-day retention, a Logs Insights query, a CloudWatch dashboard, and alarms that send email through SNS.

Each exercise ends with a list of questions the learner should be able to answer.

## Who it is for

The exercises target entry-level operations learners. The text assumes you are new to ops but not to programming.

You need these tools:

* Cursor or Claude Code
* Git and the GitHub CLI (`gh`)
* The AWS CLI and an AWS account with an IAM user
* Docker
* Terraform (installed in exercise 2)
* Node.js, to run a Next.js app

## Repo layout

* `exercises/` holds the learner guide (`README.md`) and one folder per exercise (`exercise-1` to `exercise-3`).
* `terraform/` holds the shared AWS setup that the exercises depend on.
* `.cursor/rules/` holds Cursor rules: a style guide for writing exercises and the repo conventions.

## How to start

1. Read `exercises/README.md`. It explains how to work with AI and what quality habits to build.
2. Do `exercises/exercise-1/README.md`.
3. Continue with exercises 2 and 3 in order.

Each exercise asks you to commit your work to your own GitHub repository. Never commit Terraform state files or `.env` files.

## The Terraform in `terraform/`

This code is the "central" Terraform that exercise 2 refers to. It is not one of the exercises. It creates:

* Two Route53 hosted zones, with DNS records for one of them (mail and verification records).
* A wildcard ACM certificate for one zone, validated with DNS records.

Exercise 2 reads the wildcard certificate with a `data` source.

The code uses Terraform 1.5 or later and AWS provider 5.x. It runs in `us-east-1` and stores state in an S3 backend. The domains, the state bucket, and the AWS profile belong to the repo owner. Change them before you run this code in your own account.

```sh
cd terraform
terraform init
terraform plan
```
