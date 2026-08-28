#!/usr/bin/env zsh

# Get the infuse data repo ready on a fresh machine.
#
# Not a nix activation script: this needs 1Password signed in, and "1Password is
# signed in, synced, and has its agent switched on" is not a state nix can
# observe. So it is a task you run once, after setting that up.
#
# Scope is the data repo and the deploy key gitwatch pushes with. It does NOT
# re-create the symlinks that point into it — run `infuse link` by hand.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INFUSE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/infuse"
INFUSE_REMOTE="git@github.com:oschrenk/infuse-data.git"
OP_AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
AGENT_LABEL="org.nix-community.home.gitwatch-infuse"
DEPLOY_KEY="$HOME/.ssh/gitwatch_infuse_ed25519"
DEPLOY_KEY_ITEM="op://Bootstrap/sqeyxpqmfpopo2slbsr5gmklky"

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

# 5. The deploy key gitwatch pushes with. It authenticates as itself rather than
#    through the 1Password SSH agent, because an agent has to be unlocked by a
#    person and a launchd job has nobody. 1Password holds the recovery copy, not
#    the runtime path: the key is materialised once here and read from disk from
#    then on. It has no passphrase, deliberately — nothing can prompt for one —
#    and its reach is one repo, because the public half is registered on
#    infuse-data as a deploy key rather than on the account.
if [[ -f "$DEPLOY_KEY" ]]; then
  step "Deploy key already at $DEPLOY_KEY, skipping."
else
  step "Writing the gitwatch deploy key to $DEPLOY_KEY"
  mkdir -p "$(dirname "$DEPLOY_KEY")"

  # Staged through a temp file in the same directory, so a failed or partial
  # `op read` can never leave a truncated key that the check above would then
  # skip over on the next run.
  TMP_KEY="$(mktemp "$DEPLOY_KEY.XXXXXX")"
  trap 'rm -f "$TMP_KEY"' EXIT
  op read "$DEPLOY_KEY_ITEM/private key" > "$TMP_KEY"

  # -P "" both proves the key parses and asserts it is passphrase-free, which is
  # what the unattended daemon needs. A passphrase would make this fail here
  # rather than at the first push.
  ssh-keygen -y -P "" -f "$TMP_KEY" > /dev/null

  chmod 600 "$TMP_KEY"
  mv "$TMP_KEY" "$DEPLOY_KEY"
  trap - EXIT

  op read "$DEPLOY_KEY_ITEM/public key" > "$DEPLOY_KEY.pub"
  chmod 644 "$DEPLOY_KEY.pub"
fi

# 6. Kickstart the gitwatch agent so it picks up the now-existing directory
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
