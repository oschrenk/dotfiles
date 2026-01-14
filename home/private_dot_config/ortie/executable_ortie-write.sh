#!/bin/bash
# Write token to macOS Keychain
# Ortie pipes JSON token data to stdin

# Read all of stdin - cat reads everything until EOF
token=$(cat)

# Debug: show what we received
echo "Received ${#token} bytes" >&2

# Store in Keychain (-U means update if exists, create if not)
security add-generic-password -s "ortie-token" -a "personal" -w "$token" -U
