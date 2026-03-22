# Exercise 1

Create a Next.js application that writes data to a DynamoDB database.

## Key objectives

* Set up an application workspace
* Manage local resources with Docker
* Understand the local development lifecycle

## Requirements

### Install the AWS CLI

Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html). The AWS CLI is used to interact with DynamoDB even when it's running locally in Docker (e.g., creating tables, querying data).

### Create a docker-compose.yml stack

* Add a container for amazon/dynamodb-local with a persistent volume
* Add a container for a dynamodb admin that can browse the DynamoDB data in the web browser

### The Website Guestbook

Use a modern standard framework for local development (Next.js CLI, Vite, etc).

Create a welcoming web application that hosts a Guestbook. It's 1997 again and you want to see who is visiting your website. Since Geocities is down, we're going to host our own using Next.js and DynamoDB.

Add inputs to the home page for First Name and Last Name.

When the user submits their name, add a record to a DynamoDB table named `guestbook` that stores the first name, last name, and timestamp.

To prevent the database from ballooning, and because this is a learning exercise, when a new record is saved, delete old records until no more than 100 records remain. Consider how you would query for the oldest records — this will teach you about DynamoDB's partition key and sort key model.

When configuring the application for local development:

* Use `.env` files to configure the DynamoDB endpoint (e.g., `http://localhost:8000` for local development). Prefer `.env` files over exporting variables in your shell — they are portable, self-documenting, and easy for other developers (and CI) to replicate
* Use the modern, "strict" and "stylistic" rules for `eslint`
* Use jest for unit tests
* Ensure that there is at least some test coverage for the front end
* Use the backend (api routes) for communication with DynamoDB
* Ensure that there is at least some test coverage for the back end
* Set up a `.gitignore` that excludes `node_modules`, `.env` files, and other generated artifacts

### Git repository

Submit the full exercise to a git repository named `guestbook-exercise`. The repository should be private and add me as a collaborator.

The repository should at least contain a README explaining the structure of the application. In addition to the README, add other .md documents as you see fit.

Explain the key takeaways in markdown files and ensure you are able to answer questions as if there will be a quiz.

## Key takeaways

* **Docker & local infrastructure**: Learn to manage Docker and use docker-compose stacks for local development to mimic the resources that would be available in a deployed environment.
* **Application architecture**: Understand the separation between frontend (browser) and backend (API routes), and why the backend mediates access to the database.
* **Configuration via `.env` files**: Learn the pattern of configuring applications through environment variables so the same code can run locally and in production without changes.
* **DynamoDB fundamentals**: Understand the basics of a NoSQL key-value store — partition keys, sort keys, and how queries differ from scans.
* **Code quality**: Establish habits around linting, testing, and project hygiene (`.gitignore`, README, consistent `package.json` scripts like `dev`, `test`, `lint`).

## Next steps

After this exercise is complete, we will use this same project to create resources in AWS and deploy with GitHub Actions. We will learn to configure infrastructure as code with Terraform and set up a CI/CD pipeline.

## Questions you should be able to answer

After completing this, you should be able to answer these questions:

### Docker & Local Development

* What is the difference between a Docker image and a container?
* What does `docker-compose` give you that running individual `docker run` commands doesn't?
* What is a Docker volume and why did we use one for DynamoDB?
* If you run `docker-compose down` and then `docker-compose up` again, is your data still there? Why or why not?

### Application Architecture

* Why do we use API routes to talk to DynamoDB instead of calling it directly from the browser?
* Trace the full lifecycle of a request: what happens from the moment a user clicks "Submit" to the moment they see a confirmation? (Browser -> Next.js API route -> AWS SDK -> DynamoDB -> response)
* What would happen if you put your database credentials in client-side JavaScript?

### AWS & DynamoDB

* Locally, what credentials are used by the web application to write to DynamoDB?
* In an AWS environment, how would the application gain access to DynamoDB?
* What is a partition key? What is a sort key? What did you choose for the guestbook table and why?
* What is the difference between a `Query` and a `Scan` in DynamoDB?
* Why DynamoDB? What other data stores could I use for this type of data? Why might Redis be a poor choice for persistent guestbook data?

### Configuration & Environment

* What is a `.env` file and why do we use it instead of exporting variables in the shell?
* Why should `.env` files never be committed to git?
* How does the same codebase connect to local DynamoDB during development and real DynamoDB in production?

### Testing & Code Quality

* What is linting and why does it matter?
* How is unit test coverage calculated?
* What is the difference between a unit test and an integration test? Which type did you write?

### Git & Project Hygiene

* What belongs in `.gitignore` and why?
* What is the purpose of a README?

### Bigger Picture

* Right now the app only runs on your laptop. What would need to change to make it accessible on the internet?