# Exercise 2: Deploy the Guestbook

In this exercise we will deploy the Guestbook application to ECS Fargate. We will keep costs down by using the default VPC with public subnets and relying on security groups for access control.

## Key objectives

* Build your application as a deployable container image
* Create base infrastructure for the application using Terraform
* Deploy the application to a public domain
* Understand IAM roles, security groups, and the deployment lifecycle

## Requirements

### Setup

**Install Terraform from Terraform's website**. For WSL, I recommend installing the static binary to a directory under your $HOME directory on your $PATH. Hint: after install, `terraform -version` should work in a terminal.

**Store AWS credentials**. Log in to AWS with your IAM user. Delete existing Access Keys you have attached to your IAM user. Create a new Access Key and store the credentials in `~/.aws/credentials`. Hint: after this works, you should be able to run `aws sts get-caller-identity`.

In real world scenarios, it's better to use something other than IAM User Access Keys. It's better to assume an **IAM Role** using SAML or some other mechanism. We won't worry about that today.

**Terraform state**. Store your Terraform state in S3 using the key prefix `guestbook/main/` (e.g., `guestbook/main/terraform.tfstate`).

### Build the application

Create a Dockerfile that builds your application for production deployment. Use a **multi-stage build**: one stage to build the application (`npm run build`) and a second stage to create the final production image. The production image should be as small as possible — no dev dependencies, no source code that isn't needed at runtime.

You should be able to run `docker build` to build the image and `docker run` to run the image locally — verifying that the built container works before pushing it anywhere. Hint: Ask Cursor to run the image with env variables to communicate with your compose stack.

**Important**: `.env` files do NOT go in the image. In production, configuration is injected through the ECS task definition's environment variables. Your app should already support this from exercise 1 since it reads from `process.env`.

### Set up core infrastructure

In your application directory, create a `terraform/` directory. This will be the base of your terraform root module. The root module should contain two submodules: `app` and `iam`.

#### IAM module

The `iam` module should contain the IAM Roles needed for the application. There are two distinct roles and it is important to understand the difference:

* **ECS Task Execution Role** — used by the Fargate *platform* to pull container images from ECR and write logs to CloudWatch. This role is not available to your application code. AWS provides a managed policy (`AmazonECSTaskExecutionRolePolicy`) that covers exactly these permissions.
* **ECS Task Role** — assumed by your *running application*. This is how your Next.js code gets permission to read/write DynamoDB. No AWS credentials are stored in the container; the SDK automatically uses this role. Apply the **principle of least privilege**: this role should only allow the specific DynamoDB actions your app needs (`dynamodb:PutItem`, `dynamodb:Query`, `dynamodb:DeleteItem`, etc.) on the specific table ARN — not `dynamodb:*` on `*`.

#### App module

The `app` module should contain the application infrastructure:

* ECR repository
* ECS Cluster
* ECS Task Definition (referencing both IAM roles, container image, environment variables, log configuration)
* ECS Service (desired count = 2, `assign_public_ip = true`, attached to ALB target group)
* Auto Scaling target and policy (min = 2, max = 2 — this introduces the autoscaling resource pattern without scaling surprises)
* ALB + listeners (HTTPS:443 forwarding to target group, HTTP:80 redirecting to HTTPS)
* ALB Target Group (with a health check endpoint on the app)
* Security Groups (see below)
* DynamoDB table (on-demand billing)
* Route53 A record aliasing `guestbook.example.com` to the ALB
* CloudWatch log group

The ACM wildcard certificate for `*.example.com` lives in the central `ops-101` terraform. Reference it in your exercise using a `data` source.

#### Networking and Security Groups

In production, you would place ECS tasks in private subnets with a NAT Gateway or VPC endpoints for outbound access. That adds ~$20-30/month in costs we don't need for a learning exercise.

Instead, we use the default VPC's public subnets with `assign_public_ip = true` so the tasks can reach ECR and other AWS services. **Security groups are the enforcement layer**:

* **ALB Security Group**: allows inbound traffic on ports 80 and 443 from anywhere (`0.0.0.0/0`). This is the only resource that should accept traffic from the internet.
* **ECS Security Group**: allows inbound traffic *only* from the ALB security group. Even though the tasks have public IPs, no unsolicited traffic can reach them.

This pattern gives you the same inbound access control as private subnets at zero additional cost.

### Deployment

Write a shell script (e.g., `deploy.sh`) that performs a full deployment:

1. Build the Docker image
2. Authenticate to ECR (`aws ecr get-login-password`)
3. Tag and push the image to ECR
4. Force a new deployment on the ECS service (`aws ecs update-service --force-new-deployment`)

After the initial deployment, make a cosmetic change to the application (update the title, change a color) and re-deploy using the script. Verify the change is live at `guestbook.example.com`.

This is a manual deployment. In a later exercise we will automate it.

## Key Takeaways

* **Infrastructure as Code**: Terraform makes infrastructure reproducible, reviewable, and version-controlled. You can tear it all down and recreate it identically.
* **Containers for deployment**: A Dockerfile packages your app the same way for local development and production. The image is the deployment artifact.
* **IAM roles and least privilege**: Each component gets only the permissions it needs. The platform gets one role, your code gets another. No credentials are stored in the container.
* **Security groups as network boundaries**: Even without private subnets, security groups control exactly which traffic can reach each resource. The ALB is the front door; everything else is locked down.
* **The deployment lifecycle**: Build, push, deploy. Understanding each manual step prepares you to automate it intelligently later.

## Next steps

In the next exercise, we'll look at observability:

* Monitoring
* Logging

## Questions you should be able to answer

After completing this, you should be able to answer these questions:

### Docker & Images

* What is a multi-stage Docker build and why use one?
* What is the difference between running your app locally with `docker-compose` and deploying it to Fargate?
* Why don't we include `.env` files in the Docker image?

### Terraform & Infrastructure as Code

* What is Terraform state and why does it matter?
* What happens if two people run `terraform apply` at the same time?
* What is the difference between a Terraform module and a root module?
* If you run `terraform destroy`, what happens? Can you get it all back?

### IAM & Security

* What is the difference between the ECS task execution role and the task role?
* What is the principle of least privilege?
* Why don't we put AWS credentials in the container? How does the application access DynamoDB without them?

### Networking & Security Groups

* What does the ALB do? Why not expose the ECS tasks directly?
* Why does the ECS security group only allow inbound traffic from the ALB security group?
* What is a target group health check and why is it important?
* In production, why would you use private subnets instead of the public subnet + security group approach we used here?

### Deployment

* Walk through what happens when you run the deploy script, step by step.
* How does ECS know to use the new container image?
* What is a rolling deployment? What happens to in-flight requests during a deploy?

### Bigger Picture

* What are the risks of this manual deployment process?
* What would you automate first?
