#!/usr/bin/env fish
#
# Requirements:
#   - `git`: brew install git
#   - `jira`: brew install ankitpokhrel/jira-cli/jira-cli
#
# Configuration:
#   - jira-cli needs to be authorized
#   - jira-cli needs to be initialized with the correct board
#   - the target board needs to be at $HOME/.config/.jira/$board_name.yml
#   - the target board needs to be set `git config --local jira.board BOARD`

# fail early if git not in $PATH
if not type -q "git"
  echo "Error: Could not find \"git\" in \$PATH" >&2
  exit 1
end

# fail early if jira not in $PATH
if not type -q "jira"
  echo "Error: Could not find \"jira\" in \$PATH" >&2
  exit 1
end

# accept path to repository
set -x path_to_repo $argv[1]

# return early if not valid directory
if not test -d "$path_to_repo"
  echo "Error: \"$path_to_repo\" is not a valid path to a repo" >&2
  exit 1
end

set -x board_name (git -C "$path_to_repo" config --local --get jira.board 2>/dev/null)

# return early if we couldn't retrieve a board name
# this checks if path is repository, and properly configured
if test $status -ne 0
  echo "Error: \"jira.board\" is not configured." >&2
  exit 1
end

set -x jira_config_path $HOME/.config/.jira/$board_name.yml

# return early if board config doesn't exist
if not test -e "$jira_config_path"
  echo "Error: \"$jira_config_path\" not found" >&2
  exit 1
end

# execute
jira --config $jira_config_path issue list --plain --no-headers -a$(jira me) -s"In Progress" | head -3 | awk '{print $2}' | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
