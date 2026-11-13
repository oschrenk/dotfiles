#!/bin/bash
# PreToolUse hook for Bash.
# Denies the first merge call per session and MR, and puts the repo's deployment.md in the deny
# reason, without the section for the other target (## Staging or ## Production).
# A second identical merge call passes. A memory note did not stop a production merge
# without its procedure; this does not depend on remembering.
set -euo pipefail

input=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$input")
session=$(jq -r '.session_id // "none"' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")

# release.sh tags production; hold it once with the Releasing steps, so the previous tag's
# deploy check comes first
# only as a command (start, or after ; & | or a bash prefix), not as text in a message
if [[ "$command" =~ (^|[\;\&\|][[:space:]]*|bash[[:space:]]+)([^[:space:]\;\&\|]*/)?release\.sh([[:space:]]|$) ]]; then
  marker_dir="${TMPDIR:-/tmp}/claude-merge-gate"
  repo_root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null || true)
  marker="$marker_dir/${session}-release-${repo_root//\//_}"
  [[ -f "$marker" ]] && exit 0
  mkdir -p "$marker_dir"
  touch "$marker"
  file="$repo_root/deployment.md"
  if [[ -f "$file" ]]; then
    body=$(awk '/^### / { keep = ($0 == "### Releasing") } keep' "$file")
  else
    body="No deployment.md in ${repo_root:-the current directory}. Find this repo's release procedure first."
  fi
  reason="release.sh is held once. Read the Releasing steps below ($file). In your reply, list each step and say done or not done, BEFORE release.sh. Oliver's explicit OK for this release, given in this session, is one of them. Then repeat the same command; it passes on the second call.

$body"
  jq -n --arg reason "$reason" '{hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }}'
  exit 0
fi

iid=""
project=""
if [[ "$command" =~ merge_requests/([0-9]+)/merge([^a-z_]|$) ]] && grep -Eq -- '-X[[:space:]]*PUT|--method[[:space:]]+PUT' <<<"$command"; then
  iid=${BASH_REMATCH[1]}
  [[ "$command" =~ projects/([^/[:space:]\"\']+)/merge_requests ]] && project=${BASH_REMATCH[1]}
elif [[ "$command" =~ glab[[:space:]]+mr[[:space:]]+merge([[:space:]]+([0-9]+))? ]]; then
  iid=${BASH_REMATCH[2]:-current}
else
  exit 0
fi

repo_root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "$project" && -n "$repo_root" ]]; then
  project=$(git -C "$repo_root" remote get-url origin 2>/dev/null | sed -E 's#^.*[:/]([^/]+/[^/]+)\.git$#\1#; s#/#%2F#')
fi

target=""
if [[ "$iid" == current ]]; then
  target=$(cd "${repo_root:-.}" && glab mr view -F json 2>/dev/null | jq -r '.target_branch // empty' || true)
elif [[ -n "$project" ]]; then
  target=$(glab api "projects/$project/merge_requests/$iid" 2>/dev/null | jq -r '.target_branch // empty' || true)
fi

case "$target" in
  staging) other_section=Production ;;
  production) other_section=Staging ;;
  # e.g. devops merges to master; its deployment.md has no Staging/Production split
  *) other_section="" ;;
esac

marker_dir="${TMPDIR:-/tmp}/claude-merge-gate"
marker="$marker_dir/${session}-${project//\%2F/_}-${iid}-${target:-unknown}"
if [[ -f "$marker" ]]; then
  exit 0
fi
mkdir -p "$marker_dir"
touch "$marker"

decoded_project=${project//\%2F//}
overlay="$HOME/.local/share/infuse/git.timewax.com/${decoded_project}"
file=""
for candidate in "$repo_root/deployment.md" "$overlay/deployment.md"; do
  if [[ -f "$candidate" ]]; then
    file=$candidate
    break
  fi
done

if [[ -n "$file" ]]; then
  if [[ -n "$other_section" ]]; then
    # drop the other target's section so the agent cannot follow the wrong steps
    body=$(awk -v drop="## $other_section" '/^## / { skip = ($0 == drop) } !skip' "$file")
  else
    body=$(cat "$file")
  fi
  reason="Merge of MR !$iid into '${target:-unknown target}' is held once. Read the procedure below ($file). In your reply, list each step of the matching section and say done or not done for each, BEFORE the merge step. Do the steps that come before the merge (for example the Slack post). Then repeat the same merge command; it passes on the second call.

$body"
else
  reason="Merge of MR !$iid into '${target:-unknown target}' is held once. No deployment.md was found in $repo_root or the infuse overlay for $decoded_project. Find this repo's merge procedure (DEVELOPMENT.md, README.md) and follow it, then repeat the same merge command."
fi

jq -n --arg reason "$reason" '{hookSpecificOutput: {
  hookEventName: "PreToolUse",
  permissionDecision: "deny",
  permissionDecisionReason: $reason
}}'
