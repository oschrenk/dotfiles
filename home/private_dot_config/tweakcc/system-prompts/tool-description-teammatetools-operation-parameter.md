<!--
name: 'Tool Description: TeammateTool''s operation parameter'
description: Tool description for the TeammateTool's operation parameter
ccVersion: 2.0.70
-->
Operation: spawn a teammate, spawnTeam to create a team, cleanup to remove team and task directories, read/write mailbox messages, assignTask to assign a task to a teammate, claimTask to self-claim an available task, requestShutdown to ask a teammate to shut down, approveShutdown to accept a shutdown request and exit, rejectShutdown to decline a shutdown request, approvePlan to approve a teammate plan, rejectPlan to reject a teammate plan with feedback. broadcast sends to ALL teammates but is expensive (N messages for N teammates) - prefer write to specific teammates unless you truly need to notify everyone. Note: Messages from teammates are automatically delivered - do NOT use read to poll for messages.
