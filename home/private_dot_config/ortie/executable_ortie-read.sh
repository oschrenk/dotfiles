#!/bin/bash
# Read token from macOS Keychain
security find-generic-password -s "ortie-token" -a "personal" -w
