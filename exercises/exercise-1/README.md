# Exercise 1

Create a Next.js application that writes data to a DynamoDB database.

## Key objectives

* Set up an application workspace
* Manage local resources with Docker
* Understand the local development lifecycle

## Requirements

### Install the AWS CLI

### Create a docker-compose.yml stack

* Add a container for amazon/dynamodb-local with a persistent volume
* Add a container for a dynamodb admin that can browse the DynamoDB data in the web browser

### The Website Guestbook

Use a modern standard framework for local development (Next.js CLI, Vite, etc).

Create a welcoming web application that hosts a Guestbook. It's 1997 again and you want to see who is visiting your website. Since Geocities is down, we're going to host our own using Next.js and DynamoDB.

Add inputs to the home page for First Name and Last Name.

When the user submits their name, add a record to a DynamoDB table named `guestbook` that stores the first name, last name, and timestamp.

To prevent the database from ballooning, and because this is a learning exercise, when a new record is saved, delete old records until no more than 100 records remain.

When configuring the application for local development:

* Use the modern, "strict" and "stylistic" rules for `eslint`
* Use jest for unit tests
* Ensure that there is at least some test coverage for the front end
* Use the backend (api routes) for communication with DynamoDB
* Ensure that there is at least some test coverage for the back end.

### Git repository

Submit the full exercise to a git repository named `guestbook-exercise`. The repository should be private and add me as a collaborator.

The repository should at least contain a README explaining the structure of the application. In addition to the README, add other .md documents as you see fit.

Explain the key takeaways in markdown files and ensure you are able to answer questions as if there will be a quiz.

## Key takeaways

Learn to manage Docker and use docker-compose stacks for local development to mimic the resources that would be available in the deployed environment.

## Next steps

After this exercise is complete, we will use this same project to create resources in AWS and deploy with GitHub.

## Questions you should be able to answer

After completing this, you should be able to answer these questions

* Locally, what credentials are used by the web application to write to DynamoDB?
* In an AWS environment how would the application gain access to DynamoDB?
* How exactly does data flow to DyanmoDB?
* Why DynamoDB? What other data stores could I use for this type of data? Why would Redis be a bad idea?
* How is unit test coverage calculated?