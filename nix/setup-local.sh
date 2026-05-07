#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$SCRIPT_DIR/local.nix"

echo "Creating $OUT"
echo ""
echo "This file sets personal identity values (name, email, SSH key, timezone)"
echo "used across all nix configurations on this machine. Run once per machine."
echo "Never stage or commit it — but ultimately that's on you."
echo ""
echo "Press Enter to accept a detected value, or type to override."
echo ""

# Detect defaults
_username="$(whoami)"
_name="$(id -F 2>/dev/null || echo "")"
_email="$(git config --global user.email 2>/dev/null || echo "")"
_timezone="$(readlink /etc/localtime 2>/dev/null | sed 's|.*zoneinfo/||' || echo "UTC")"
_sshKey="$(cat "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || echo "")"

prompt() {
  local label="$1" default="$2" varname="$3"
  if [[ -n "$default" ]]; then
    read -rp "$label [$default]: " input
    printf -v "$varname" '%s' "${input:-$default}"
  else
    read -rp "$label: " input
    printf -v "$varname" '%s' "$input"
  fi
}

prompt "username" "$_username" username
prompt "name    " "$_name"     name
prompt "email   " "$_email"    email
prompt "timezone" "$_timezone" timezone
prompt "SSH public key (full ssh-ed25519 ... line)" "$_sshKey" sshKey

cat > "$OUT" <<EOF
{ ... }:
{
  my.personal.username = "$username";
  my.personal.name     = "$name";
  my.personal.email    = "$email";
  my.personal.timezone = "$timezone";
  my.personal.sshKey   = "$sshKey";
}
EOF

echo ""
echo "Written to $OUT"
echo "Run 'task nix-max' to apply."
