<!--
name: 'Tool Description: TaskUpdate'
description: 'Description for the TaskUpdate tool, which updates Claude''s task list'
ccVersion: 2.0.72
-->
Use this tool to update a task in the task list.

## When to Use This Tool

**Mark tasks as resolved:**
- When you have completed the work described in a task
- When a task is no longer needed or has been superseded
- IMPORTANT: Always mark your assigned tasks as resolved when you finish them
- After resolving, call TaskList to find your next task

**Update task details:**
- When requirements change or become clearer
- When you need to add context via comments
- When establishing dependencies between tasks

## Fields You Can Update

- **status**: Set to 'resolved' when work is complete, or 'open' to reopen
- **subject**: Change the task title
- **description**: Change the task description
- **addComment**: Add a comment with {author, content} to track progress or decisions. **Teammates**: Use your \`CLAUDE_CODE_AGENT_ID\` environment variable as the author. 
- **addReferences**: Link to related tasks (bidirectional)
- **addBlocks**: Mark tasks that cannot start until this one completes
- **addBlockedBy**: Mark tasks that must complete before this one can start

## Task Ownership (IMPORTANT)

**You MUST claim a task before updating it.** In a team context, you can only update tasks that are assigned to you.

To claim a task, use TeammateTool with the \`assignTask\` or \`claimTask\` operation:
- Team lead can assign tasks to teammates using \`assignTask\`
- Teammates can self-claim using \`claimTask\`

Attempting to update an unclaimed task or a task owned by another agent will fail with an error. Team leads can update any task.

Teammates should add comments while working to signal progress to the team and team lead.

## Staleness

Make sure to read a task's latest state using \`TaskGet\` before updating it.

## Examples

Mark task as resolved after completing work:
\`\`\`json
{"taskId": "1", "status": "resolved"}
\`\`\`

Add a progress comment (use your CLAUDE_CODE_AGENT_ID as author):
\`\`\`json
{"taskId": "2", "addComment": {"author": "your-agent-id-here", "content": "Found the root cause, fixing now"}}
\`\`\`

Mark resolved with a completion comment:
\`\`\`json
{"taskId": "3", "status": "resolved", "addComment": {"author": "your-agent-id-here", "content": "Implemented and tested"}}
\`\`\`
