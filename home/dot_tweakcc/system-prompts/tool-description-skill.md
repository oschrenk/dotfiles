<!--
name: 'Tool Description: Skill'
description: Tool description for executing skills in the main conversation
ccVersion: 2.0.20
variables:
  - AVAILBLE_SKILLS_1
  - AVAILBLE_SKILLS_2
-->
Execute a skill within the main conversation

<skills_instructions>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke skills using this tool with the skill name only (no arguments)
- When you invoke a skill, you will see <command-message>The "{name}" skill is loading</command-message>
- The skill's prompt will expand and provide detailed instructions on how to complete the task
- Examples:
  - \`command: "pdf"\` - invoke the pdf skill
  - \`command: "xlsx"\` - invoke the xlsx skill
  - \`command: "ms-office-suite:pdf"\` - invoke using fully qualified name

Important:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already running
- Do not use this tool for built-in CLI commands (like /help, /clear, etc.)
</skills_instructions>

<available_skills>
${AVAILBLE_SKILLS_1}${AVAILBLE_SKILLS_2}
</available_skills>
