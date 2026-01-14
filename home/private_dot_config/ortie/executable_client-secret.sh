#!/bin/bash
# Retrieve client secret from macOS Keychain

# Debug: log that we're being called
echo "client-secret.sh called at $(date)" >&2

# Try to get the secret
result=$(security find-generic-password -a MELI -s meli-cli -w 2>&1)
exit_code=$?

# Debug: log the result
echo "security command exit code: $exit_code" >&2
echo "Result length: ${#result} chars" >&2

if [ $exit_code -ne 0 ]; then
    echo "ERROR: $result" >&2
    exit $exit_code
fi

# Extract client_secret from JSON
client_secret=$(echo "$result" | jq -r .client_secret 2>&1)
jq_exit_code=$?

echo "jq exit code: $jq_exit_code" >&2

if [ $jq_exit_code -ne 0 ]; then
    echo "ERROR parsing JSON: $client_secret" >&2
    exit $jq_exit_code
fi

# Output the client secret
echo "$client_secret"
