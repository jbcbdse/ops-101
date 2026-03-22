# Exercises

Exercises in this repository are targeted toward entry-level OPS learning with AI-first development in mind. You are expected to use Cursor or Claude Code to perform these exercises, and learn as much as you can about implementation detail along the way.

Each exercise should be committed to a GitHub repository. When prompted, infrastructure configuration will be stored in Terraform state files in S3. You are expected to execute Terraform locally. Ensure that that Terraform state files are NEVER committed to git.

## Working with AI

Use `plan` mode for big changes. Give Claude very precise instructions, which will always use context from .md files and other files in your project. Evaluate the plan yourself very closely before building.

For later, smaller, incremental changes, use `agent` mode.

If you want to ask Claude questions without it taking action use `ask` mode.

Create `rules` in Cursor for instructions that you always want to be present.

Create `skills` in Cursor or Claude Code for very long instructions that should only be read into context when they are relevant. A skill should have a short description but may have hundreds of lines of instructions for Claude to execute to perform an action.

Install the AWS CLI and the `gh` (GitHub) CLI. Both of these are essential tools that you will use throughout these exercises. Claude can use these CLIs directly, so having them installed means your AI assistant can execute AWS and GitHub operations on your behalf. You may want a `rule` to tell the LLM it is installed.

If you don't know how to do something, ask Claude and learn a step at a time. Avoid having Claude do large units of work that you do not understand and can not evaluate for correctness.

Ask Claude to check its own work. Ask Claude to explain it to you. Switch to a different model for a different opinion.

## You Own the Code

AI writes fast, but **you are responsible for every line**. Read what it produces. If you can't explain why a line exists, ask until you can. "Claude wrote it" is never an acceptable answer in a code review.

Never accept large diffs without reviewing them. If Claude generated more than a screenful of changes, slow down and read before moving on.

## Quality is Not a Phase

Quality is not something you bolt on at the end. Build these habits from the first line of code:

* **Lint before you commit.** Set up linting early and keep it clean. Ask Claude to fix lint errors — don't ignore them.
* **Test as you build.** Don't write all the code and then "add tests later." Ask Claude to write tests alongside the implementation. Run them. Understand what they cover and what they don't.
* **Small, meaningful commits.** Each commit should represent one logical change with a clear message. Use Claude to help write commit messages, but make sure they describe *why*, not just *what*.
* **Never commit secrets.** No `.env` files, no API keys, no credentials in git. Ever. If you accidentally commit one, consider it compromised — rotating the secret is the only safe move.

## Think Before You Prompt

The quality of Claude's output is directly proportional to the quality of your instructions. Be specific about what you want, provide context, and constrain the scope. "Build me a web app" will give you something generic. "Add a POST endpoint at `/api/guestbook` that validates first/last name and writes to DynamoDB" will give you something useful.

When something breaks, resist the urge to say "fix it." Instead, describe the symptom, share the error, and ask Claude to explain the root cause before applying a fix. You'll learn more and get better solutions.