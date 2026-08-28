#!/usr/bin/env zsh

# Get the infuse data repo ready on a fresh machine.
#
# Not a nix activation script: this needs the 1Password SSH agent, and
# "1Password is signed in, synced, and has its agent switched on" is not a state
# nix can observe. So it is a task you run once, after setting that up.
#
# Scope is the data repo only. It does NOT re-create the symlinks that point
# into it — run `infuse link` by hand for those.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INFUSE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/infuse"
INFUSE_REMOTE="git@github.com:oschrenk/infuse-data.git"
OP_AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
AGENT_LABEL="org.nix-community.home.gitwatch-infuse"

step() { echo; echo "==> $*"; }

# 1. Precondition: the 1Password SSH agent. infuse-data is private, so the clone
#    needs real credentials. Exit 0, not 1 — a machine that is only part-way
#    through 1Password setup is not broken, it is just not ready yet.
if [[ ! -S "$OP_AGENT_SOCK" ]]; then
  echo "1Password SSH agent not found at:"
  echo "  $OP_AGENT_SOCK"
  echo
  echo "infuse-data is a private repo, so the clone needs it. To set it up:"
  echo "  1. Open 1Password and sign in"
  echo "  2. Wait for the initial sync to finish"
  echo "  3. Settings > Developer > enable 'Use the SSH agent'"
  echo
  echo "Then re-run: task bootstrap:infuse"
  exit 0
fi
export SSH_AUTH_SOCK="$OP_AGENT_SOCK"

# 2. Clone if missing.
if [[ -d "$INFUSE_DIR/.git" ]]; then
  step "infuse repo already at $INFUSE_DIR, skipping clone."
else
  step "Cloning $INFUSE_REMOTE into $INFUSE_DIR"
  mkdir -p "$(dirname "$INFUSE_DIR")"
  git clone "$INFUSE_REMOTE" "$INFUSE_DIR"
fi

# 3. Repo-local identity. git.nix sets user.name globally but deliberately never
#    user.email (user.useConfigOnly = true), so each repo supplies its own or
#    commits fail. The gitwatch agent commits here unattended, so it needs one.
EMAIL="$(nix eval --raw --impure --expr "(import $REPO_ROOT/nix/identity.nix {}).my.personal.email")"
CURRENT_EMAIL="$(git -C "$INFUSE_DIR" config --local --get user.email || true)"

if [[ "$CURRENT_EMAIL" == "$EMAIL" ]]; then
  step "Repo-local user.email already set to $EMAIL, skipping."
else
  step "Setting repo-local user.email to $EMAIL"
  git -C "$INFUSE_DIR" config user.email "$EMAIL"
fi

# 4. Repo-local signing off. git.nix turns on commit and tag signing globally,
#    but gitwatch commits through libgit2, which never calls the signer. Leaving
#    it on would sign only the commits made by hand, so half the history in here
#    would read as unverified. Off in both cases is the consistent answer.
for KEY in commit.gpgsign tag.gpgsign; do
  if [[ "$(git -C "$INFUSE_DIR" config --local --get "$KEY" || true)" == "false" ]]; then
    step "Repo-local $KEY already false, skipping."
  else
    step "Setting repo-local $KEY to false"
    git -C "$INFUSE_DIR" config "$KEY" false
  fi
done

# 5. Kickstart the gitwatch agent so it picks up the now-existing directory
#    instead of waiting for its next crash-restart. Only if it is loaded — on a
#    fresh machine this script may run before the first nix-darwin switch.
if launchctl print "gui/$(id -u)/$AGENT_LABEL" >/dev/null 2>&1; then
  step "Restarting $AGENT_LABEL"
  launchctl kickstart -k "gui/$(id -u)/$AGENT_LABEL"
else
  step "$AGENT_LABEL not loaded yet — it will start after 'task nix:rebuild:darwin'."
fi

echo
echo "Done. Watching: $INFUSE_DIR"
echo "Log: ~/Library/Logs/gitwatch-infuse.log"
