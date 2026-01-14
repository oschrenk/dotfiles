#!/usr/bin/env sh
# Write token to macOS Keychain
#
# Ortie pipes JSON token data to stdin
# But... `security` doesn't support stdin, 
# so we store it in $token and then place it

# read stdin until EOF
token=$(cat)

# store in keychain 
#   -U means update if exists, create if not
security add-generic-password -s "ortie-token" -a "personal" -w "$token" -U
