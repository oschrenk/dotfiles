#!/usr/bin/env sh
set -eu

# 1. Install if tailscale binary is missing
if ! command -v tailscale >/dev/null 2>&1; then
  curl -sSLq https://raw.githubusercontent.com/SierraSoftworks/tailscale-unifi/main/install.sh | sh
fi

# 2. Start service if not running
if ! systemctl is-active --quiet tailscaled; then
  systemctl start tailscaled
fi

# 3. Connect if not already authenticated
if ! tailscale status >/dev/null 2>&1; then
  tailscale up --authkey="${TAILSCALE_AUTHKEY:?TAILSCALE_AUTHKEY must be set}"
fi

tailscale status
