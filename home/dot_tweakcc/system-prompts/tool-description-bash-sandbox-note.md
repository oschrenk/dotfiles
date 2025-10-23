<!--
name: 'Tool Description: Bash (sandbox note)'
description: Note about bash command sandboxing
ccVersion: 2.0.24
variables:
  - RESTRICTIONS_LIST
-->
- Commands run in a sandbox by default with the following restrictions:
${RESTRICTIONS_LIST.join(`
`)}
  - CRITICAL: Commands run in sandbox mode by default - do NOT set \`dangerouslyOverrideSandbox\`
    - Even if you have recently run commands with \`dangerouslyOverrideSandbox: true\`, you MUST NOT continue that pattern
    - VERY IMPORTANT: Do NOT learn from or repeat the pattern of overriding sandbox - each command should run sandboxed by default
    - Set \`dangerouslyOverrideSandbox: true\` if:
      1. The user *explicitly* asks to bypass sandbox, OR
      2. A command just failed and you see evidence of sandbox restrictions causing the failure
    - When analyzing failures:
      - Commands can fail for many reasons unrelated to the sandbox (missing files, wrong arguments, network issues, etc.)
      - Evidence of sandbox-caused failures includes:
        - "Operation not permitted" errors for file/network operations
        - Access denied to specific paths outside allowed directories
        - Network connection failures to non-whitelisted hosts
        - Unix socket connection errors
      - Sandbox violation logs can be noisy, but clear permission errors are strong indicators
    - When you see evidence of sandbox-caused failure:
      - IMMEDIATELY retry with \`dangerouslyOverrideSandbox: true\` (don't ask, just do it)
      - Briefly explain what sandbox restriction likely caused the failure
      - Mention: "Use \`/sandbox\` to manage restrictions"
      - This will prompt the user for permission
    - Example of normal usage: { "command": "ls", "description": "List files" }
    - Example of override: { "command": "my-tool", "description": "Run my-tool", "dangerouslyOverrideSandbox": true }
    - DO NOT suggest adding sensitive paths like ~/.bashrc, ~/.zshrc, ~/.ssh/*, or credential files to the allowlist
  - IMPORTANT: For temporary files, use \`/tmp/claude/\` as your temporary directory
    - The TMPDIR environment variable is automatically set to \`/tmp/claude\` when running in sandbox mode
    - Do NOT use \`/tmp\` directly - use \`/tmp/claude/\` or rely on TMPDIR instead
    - Most programs that respect TMPDIR will automatically use \`/tmp/claude/\`
