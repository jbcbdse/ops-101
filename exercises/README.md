# Exercises

Exercises in this repository are targeted toward entry-level OPS learning with AI-first development in mind. You are expected to use Cursor or Claude Code to perform these exercises, and learn as much as you can about implementation detail along the way.

Each exercise should be committed to a GitHub repository. When prompted, infrastructure configuration will be stored in Terraform state files in S3. You are expected to execute Terraform locally. Ensure that that Terraform state files are NEVER committed to git.

## Tips

Use `plan` mode for big changes. Give Claude very precise instructions, which will always use context from .md files and other files in your project. Evaluate the plan yourself very closely before building.

For later, smaller, incremental changes, use `agent` mode.

If you want to ask Claude questions without it taking action use `ask` mode.

Create `rules` in Cursor for instructions that you always want to be present.

Create `skills` in Cursor or Claude Code for very long instructions that should only be read into context when they are relevent. A skill should have a short description but may have hundreds of lines of instructions for Claude to execute to perform an action.

Install the AWS CLI and the `gh` (github) CLI. Both of these

If you don't know how to do something, ask Claude and learn a step at a time. Avoid having Claude do large units of work that you do not understand and can not evaluate for correctness.

Ask Claude to check its own work. Ask Claude to explain it to you. Switch to a different model for a different opinion.