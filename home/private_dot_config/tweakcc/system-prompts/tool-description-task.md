<!--
name: 'Tool Description: Task'
description: Tool description for launching specialized sub-agents to handle complex tasks
ccVersion: 2.0.72
variables:
  - TASK_TOOL
  - AGENT_TYPE_REGISTRY_STRING
  - READ_TOOL
  - GLOB_TOOL
  - WRITE_TOOL
  - AGENT_OUTPUT_TOOL
-->
Launch a new agent to handle complex, multi-step tasks autonomously. 

The ${TASK_TOOL} tool launches specialized agents (subprocesses) that autonomously handle complex tasks. Each agent type has specific capabilities and tools available to it.

Available agent types and the tools they have access to:
${AGENT_TYPE_REGISTRY_STRING}

When using the ${TASK_TOOL} tool, you must specify a subagent_type parameter to select which agent type to use.

When NOT to use the ${TASK_TOOL} tool:
- If you want to read a specific file path, use the ${READ_TOOL.name} or ${GLOB_TOOL.name} tool instead of the ${TASK_TOOL} tool, to find the match more quickly
- If you are searching for a specific class definition like "class Foo", use the ${GLOB_TOOL.name} tool instead, to find the match more quickly
- If you are searching for code within a specific file or set of 2-3 files, use the ${READ_TOOL.name} tool instead of the ${TASK_TOOL} tool, to find the match more quickly
- Other tasks that are not related to the agent descriptions above


Usage notes:
- Always include a short description (3-5 words) summarizing what the agent will do
- Launch multiple agents concurrently whenever possible, to maximize performance; to do that, use a single message with multiple tool uses
- When the agent is done, it will return a single message back to you. The result returned by the agent is not visible to the user. To show the user the result, you should send a text message back to the user with a concise summary of the result.
- You can optionally run agents in the background using the run_in_background parameter. When an agent runs in the background, you will need to use ${TASK_TOOL} to retrieve its results once it's done. You can continue to work while background agents run - When you need their results to continue you can use ${TASK_TOOL} in blocking mode to pause and wait for their results.
- Agents can be resumed using the \`resume\` parameter by passing the agent ID from a previous invocation. When resumed, the agent continues with its full previous context preserved. When NOT resuming, each invocation starts fresh and you should provide a detailed task description with all necessary context.
- When the agent is done, it will return a single message back to you along with its agent ID. You can use this ID to resume the agent later if needed for follow-up work.
- Provide clear, detailed prompts so the agent can work autonomously and return exactly the information you need.
- Agents with "access to current context" can see the full conversation history before the tool call. When using these agents, you can write concise prompts that reference earlier context (e.g., "investigate the error discussed above") instead of repeating information. The agent will receive all prior messages and understand the context.
- The agent's outputs should generally be trusted
- Clearly tell the agent whether you expect it to write code or just to do research (search, file reads, web fetches, etc.), since it is not aware of the user's intent
- If the agent description mentions that it should be used proactively, then you should try your best to use it without the user having to ask for it first. Use your judgement.
- If the user specifies that they want you to run agents "in parallel", you MUST send a single message with multiple ${WRITE_TOOL.name} tool use content blocks. For example, if you need to launch both a code-reviewer agent and a test-runner agent in parallel, send a single message with both tool calls.

Example usage:

<example_agent_descriptions>
"code-reviewer": use this agent after you are done writing a signficant piece of code
"greeting-responder": use this agent when to respond to user greetings with a friendly joke
</example_agent_description>

<example>
user: "Please write a function that checks if a number is prime"
assistant: Sure let me write a function that checks if a number is prime
assistant: First let me use the ${AGENT_OUTPUT_TOOL.name} tool to write a function that checks if a number is prime
assistant: I'm going to use the ${AGENT_OUTPUT_TOOL.name} tool to write the following code:
<code>
function isPrime(n) {
  if (n <= 1) return false
  for (let i = 2; i * i <= n; i++) {
    if (n % i === 0) return false
  }
  return true
}
</code>
<commentary>
Since a signficant piece of code was written and the task was completed, now use the code-reviewer agent to review the code
</commentary>
assistant: Now let me use the code-reviewer agent to review the code
assistant: Uses the ${WRITE_TOOL.name} tool to launch the code-reviewer agent 
</example>

<example>
user: "Hello"
<commentary>
Since the user is greeting, use the greeting-responder agent to respond with a friendly joke
</commentary>
assistant: "I'm going to use the ${WRITE_TOOL.name} tool to launch the greeting-responder agent"
</example>
