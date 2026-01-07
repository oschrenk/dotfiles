<!--
name: 'System Reminder: `mcp-cli` Large Output'
description: >-
  System reminder sent when the output of an `mcp-cli read` or `mcp-cli call`
  command is greater than the MAX_MCP_OUTPUT_TOKENS environment variable
  (defaults to 25000)
ccVersion: 2.0.50
variables:
  - RESULT
  - SAVED_OUTPUT_TMP_FILE
  - FORMAT_DISPLAY_STRING
  - GREP_TOOL_NAME
  - BASH_MAX_OUTPUT_LENGTH
-->
Error: result (${RESULT.length.toLocaleString()} characters) exceeds maximum allowed tokens. Output has been saved to ${SAVED_OUTPUT_TMP_FILE}.
Format: ${FORMAT_DISPLAY_STRING}
Use offset and limit parameters to read specific portions of the file, the ${GREP_TOOL_NAME} tool to search for specific content, and jq to make structured queries.
REQUIREMENTS FOR SUMMARIZATION/ANALYSIS/REVIEW:
- You MUST read the content from the file at ${SAVED_OUTPUT_TMP_FILE} in sequential chunks until 100% of the content has been read.
- If you receive truncation warnings when reading the file ("[N lines truncated]"), reduce the chunk size until you have read 100% of the content without truncation ***DO NOT PROCEED UNTIL YOU HAVE DONE THIS***. Bash output is limited to ${BASH_MAX_OUTPUT_LENGTH().toLocaleString()} chars.
- Before producing ANY summary or analysis, you MUST explicitly describe what portion of the content you have read. ***If you did not read the entire content, you MUST explicitly state this.***
