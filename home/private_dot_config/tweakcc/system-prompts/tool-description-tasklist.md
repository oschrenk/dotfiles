<!--
name: 'Tool Description: TaskList'
description: 'Description for the TaskList tool, which lists all tasks in the task list'
ccVersion: 2.0.70
-->
Use this tool to list all tasks in the task list.

## When to Use This Tool

- To see what tasks are available to work on (status: 'open', no owner, not blocked)
- To check overall progress on the project
- To find tasks that are blocked and need dependencies resolved
- Before assigning tasks to teammates, to see what's available
- After completing a task, to check for newly unblocked work or claim the next available task

## Output

Returns a summary of each task:
- **id**: Task identifier (use with TaskGet, TaskUpdate, or assignTask)
- **subject**: Brief description of the task
- **status**: 'open' or 'resolved'
- **owner**: Agent ID if assigned, empty if available
- **blockedBy**: List of open task IDs that must be resolved first (tasks with blockedBy cannot be claimed until dependencies resolve)

Use TaskGet with a specific task ID to view full details including description and comments.

## Teammate Workflow

When working as a teammate:
1. After completing your current task, call TaskList to find available work
2. Look for tasks with status 'open', no owner, and empty blockedBy
3. Use claimTask to claim an available task, or wait for leader assignment
4. If blocked, focus on unblocking tasks or notify the team lead
