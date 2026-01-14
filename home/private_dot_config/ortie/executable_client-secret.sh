#!/usr/bin/env sh

# retrieve client secret from macOS Keychain
security find-generic-password -a MELI -s meli-cli -w | jq -r .client_secret
