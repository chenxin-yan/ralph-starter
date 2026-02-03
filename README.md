# Ralph Starter

A methodology and automation toolkit for orchestrating long-running AI coding agents through iterative task execution.

## Overview

Ralph is a shell-based approach to running AI coding agents in a continuous loop, enabling them to work through complex, multi-task projects autonomously. Instead of managing a single long session that may hit context limits or rate limits, Ralph breaks work into small, granular tasks and maintains persistent context across agent sessions.

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                      ralph.sh Loop                          │
│                                                             │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐  │
│  │  Read   │───▶│  Agent  │───▶│ Update  │───▶│  Commit │  │
│  │ prd.json│    │  Works  │    │progress │    │ Changes │  │
│  │         │    │ on Task │    │   .md   │    │         │  │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘  │
│       │                                             │       │
│       └────────────── Next Iteration ◀──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Core Components

| File          | Description                                                    |
| ------------- | -------------------------------------------------------------- |
| `prd.json`    | Project task list with small, granular, actionable items       |
| `progress.md` | Running log that acts as "memory" between agent sessions       |
| `PROMPT.md`   | System prompt template that instructs the agent each iteration |
| `SPEC.md`     | Project specification document describing what you're building |
| `ralph.sh`    | The orchestration script that runs the agent loop              |

### Workflow

1. Agent reads `prd.json` and identifies the highest-priority task with no dependencies (agent infers priority and dependencies from context)
2. Agent works on that single task, verifying implementation (tests, type checks, etc.)
3. Agent updates `progress.md` with notes for future iterations
4. Agent updates `prd.json` (marks task complete, update notes for other tasks)
5. Agent commits changes
6. Agent outputs completion signal
7. Script detects completion, starts next iteration
8. Loop continues until all tasks are complete (or max iterations reached)

## Quick Start

### Prerequisites

- An AI coding CLI tool (e.g., [opencode](https://github.com/opencode-ai/opencode), [claude](https://docs.anthropic.com/en/docs/claude-code), [aider](https://aider.chat/))
- Git
- [jq](https://jqlang.github.io/jq/) - JSON processor (install with `brew install jq` or `apt install jq`)

### Setup

1. Clone this starter:

   ```bash
   git clone https://github.com/chenxin-yan/ralph-starter.git my-project
   cd my-project
   ```

2. Configure your agent CLI command (edit `ralph.sh` or set environment variable):

   ```bash
   export RALPH_AGENT_CMD="opencode -p -q"
   ```

3. Write your project spec in `SPEC.md`:

   ```markdown
   # My Project

   ## Overview

   A brief description of what you're building.

   ## Features

   - Feature 1
   - Feature 2

   ## Technical Requirements

   - Use TypeScript
   - Use PostgreSQL for database
   ```

4. Create your `prd.json` with tasks:

   ```json
   {
     "tasks": [
       {
         "description": "Initialize the project with TypeScript and basic folder structure",
         "subtasks": [
           "Run npm init",
           "Install TypeScript and configure tsconfig.json",
           "Create src/ directory structure",
           "Verify with tsc --noEmit"
         ],
         "notes": "Use strict TypeScript settings",
         "passed": false
       }
     ]
   }
   ```

5. Run Ralph:

   ```bash
   ./ralph.sh
   ```

### Options

```bash
./ralph.sh                    # Run until all tasks complete
./ralph.sh --max-loops 10     # Limit to 10 iterations
./ralph.sh --dry-run          # Show configuration without running
./ralph.sh --help             # Show help message
```

## File Formats

### prd.json

The task list that drives the agent's work. Tasks should be small and granular - each completable in a single agent session.

| Field         | Type     | Description                                 |
| ------------- | -------- | ------------------------------------------- |
| `description` | string   | End goal - what should be achieved          |
| `subtasks`    | string[] | Ordered steps to complete the task          |
| `notes`       | string   | Context, constraints, or tips for the agent |
| `passed`      | boolean  | Whether the task is complete                |

**Note**: There is no explicit priority or dependency field. The agent analyzes the task list and determines which task to work on based on context, logical ordering, and what makes sense given the current state of the project.

### SPEC.md

The project specification document. This describes what you're building at a high level. The agent reads this to understand the overall goal and make informed decisions.

```markdown
# Project Name

## Overview

What is this project? What problem does it solve?

## Features

- Feature 1: Description
- Feature 2: Description

## Technical Stack

- Language/Framework
- Database
- Other technologies

## Architecture

High-level architecture decisions.

## Constraints

Any limitations or requirements to be aware of.
```

### PROMPT.md

The system prompt template sent to the agent each iteration. This contains the instructions that enforce the Ralph workflow.

```markdown
You are an AI coding agent working on a project. Follow these instructions exactly:

## Context Files

- Read `SPEC.md` to understand the project specification
- Read `prd.json` to see all tasks
- Read `progress.md` to understand what has been done

## Your Task

1. Analyze `prd.json` and select ONE task to work on
   - Choose the highest priority task that doesn't depend on incomplete tasks
   - Use your judgment based on task descriptions and current project state

2. Complete the selected task
   - Follow the subtasks as a guide
   - Verify your implementation (run tests, type checks, linting if available)

3. Update project files
   - Append to `progress.md` with: task completed, files changed, decisions made, notes for next agent
   - Update `notes` field in `prd.json` for related tasks if you discovered useful context
   - Mark the task as `passed: true` in `prd.json`

4. Commit your changes
   - Create a git commit with a descriptive message

5. Signal completion
   - Output: RALPH_TASK_COMPLETE

## Rules

- Work on only ONE task per session
- Always verify your work before marking complete
- Leave helpful context for the next agent iteration
```

### progress.md

The progress file is **append-only** - the agent adds new entries after each task but never modifies previous entries. This creates an immutable log that serves as a handoff document between agent sessions. Each entry is separated by `---`.

```markdown
---

## Task: Initialize project with TypeScript

### Completed

- Initialized npm project with TypeScript
- Configured strict tsconfig.json
- Created src/index.ts entry point

### Files Changed

- package.json
- tsconfig.json
- src/index.ts

### Decisions

- Using ES2022 target for modern Node.js support
- Enabled strict null checks

### Notes for Next Agent

- Ready to implement core features
- Consider adding ESLint in next task
```

## Configuration

Environment variables:

| Variable                    | Description                         | Default                                              |
| --------------------------- | ----------------------------------- | ---------------------------------------------------- |
| `RALPH_AGENT_CMD`           | Command to invoke the agent CLI     | `opencode -p -q`                                     |
| `RALPH_PRD_FILE`            | Path to task file                   | `prd.json`                                           |
| `RALPH_PROGRESS_FILE`       | Path to progress log                | `progress.md`                                        |
| `RALPH_PROMPT_FILE`         | Path to prompt template             | `PROMPT.md`                                          |
| `RALPH_SPEC_FILE`           | Path to project spec                | `SPEC.md`                                            |
| `RALPH_COMPLETE_SIGNAL`     | String agent outputs when done      | `RALPH_TASK_COMPLETE`                                |
| `RALPH_RATE_LIMIT_PATTERN`  | Regex pattern to detect rate limits | `rate.limit\|429\|quota.exceeded\|too.many.requests` |
| `RALPH_RATE_LIMIT_COOLDOWN` | Cooldown period in seconds          | `60`                                                 |

## Rate Limit Handling

The script monitors agent output for rate limit indicators and will:

- Pause execution when rate limits are detected (matches `RALPH_RATE_LIMIT_PATTERN`)
- Wait for the appropriate cooldown period
- Resume automatically

## Supported Agent CLIs

Ralph is designed to be CLI-agnostic. Configure your agent command:

| CLI      | Configuration                          |
| -------- | -------------------------------------- |
| opencode | `RALPH_AGENT_CMD="opencode -p -q"`     |
| claude   | `RALPH_AGENT_CMD="claude -p"`          |
| aider    | `RALPH_AGENT_CMD="aider --message"`    |
| Custom   | Any CLI that accepts a prompt argument |

## Tips for Writing Good Tasks

1. **Keep tasks small**: Each task should be completable and actionable in a single agent session
2. **Subtasks must be specific**: Break down the work into concrete steps (e.g., "Create POST /auth/login endpoint", "Add JWT token generation", "Write integration tests for login flow")
3. **Include verification steps**: Add subtasks for testing and verification
4. **Provide context**: Use the `notes` field to guide the agent with constraints or tips
5. **Order logically**: While the agent infers dependencies, ordering tasks logically helps

## License

MIT License - See [LICENSE](LICENSE) file
