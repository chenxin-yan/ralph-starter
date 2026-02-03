# Ralph Agent Instructions

You are an AI coding agent working through a project task by task. Each session, you complete ONE task and hand off to the next iteration.

## Step 1: Understand Context

Read these files to understand the current state:

1. **`SPEC.md`** - Project specification (what you're building)
2. **`prd.json`** - Task list with all tasks and their status
3. **`progress.md`** - Log of completed work and notes from previous iterations

## Step 2: Select a Task

From `prd.json`, select **ONE** task to work on:

- Choose a task where `passed: false`
- Analyze task descriptions and the current project state to determine the best task to work on next
- Consider logical dependencies (e.g., "add authentication" should come before "add protected routes")
- If unclear, prefer tasks listed earlier in the file

## Step 3: Complete the Task

Work through the task:

1. Follow the `subtasks` array as your implementation guide
2. Write clean, well-structured code
3. **Verify your work** before marking complete:
   - Run tests if they exist
   - Run type checks if applicable (`tsc --noEmit`, `mypy`, etc.)
   - Run linting if configured
   - Manually verify the feature works as expected

## Step 4: Update Progress

After completing the task, update `progress.md`:

- **Append only** - never modify previous entries
- Add a `---` separator before your new entry
- Include:
  - Task description
  - What was completed
  - Files changed
  - Key decisions made
  - Notes for the next iteration

Example entry:

```markdown
---

## Task: [Task description from prd.json]

### Completed
- [What you accomplished]

### Files Changed
- [List of files]

### Decisions
- [Any architectural or implementation decisions]

### Notes for Next Agent
- [Helpful context for future iterations]
```

## Step 5: Update prd.json

1. Set `passed: true` for the completed task
2. Update `notes` field of **other tasks** if you discovered relevant context
   - Example: "The database schema uses UUID primary keys" helps future tasks

## Step 6: Commit Changes

Create a git commit with a clear, descriptive message:

- Format: `feat: [brief description]` or `fix: [brief description]`
- Include what was implemented, not just "completed task"

## Step 7: Signal Completion

When finished, output this exact string on its own line:

```
RALPH_TASK_COMPLETE
```

This signals the orchestration script to start the next iteration.

---

## Important Rules

1. **One task per session** - Do not work on multiple tasks
2. **Verify before marking complete** - Ensure the implementation actually works
3. **Append-only progress** - Never edit previous progress.md entries
4. **Leave context** - Future iterations depend on your notes
5. **Commit your work** - All changes must be committed before signaling completion
