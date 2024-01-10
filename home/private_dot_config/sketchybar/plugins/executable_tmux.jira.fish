#!/usr/bin/env fish

# Requirements:
#   - `git`: brew install git
#   - `jira`: brew install ankitpokhrel/jira-cli/jira-cli
#
# Configuration:
#   - jira-cli needs to be authorized
#   - the target board needs to be set `git config --local jira.board BOARD`
#   - the target board needs to exist at $HOME/.config/.jira/$board_name.yml

function __error
    echo $argv >&2
    sketchybar --set "$NAME" drawing=off
    exit 1
end

# fail early if git not in $PATH
if not type -q git
    __error "Error: Could not find \"git\" in \$PATH"
end

# fail early if jira not in $PATH
if not type -q jira
    __error "Error: Could not find \"jira\" in \$PATH"
end

# fetch current session
set -x session_raw (tmux list-sessions -F '#{session_name}:#{session_path}' -f "#{==:#{session_attached},1}")
set -x session_name (echo "$session_raw" | cut -d ":" -f 1)
set -x path_to_repo (echo "$session_raw" | cut -d ":" -f 2)

# return early if not valid directory
if not test -d "$path_to_repo"
    __error "Error: \"$path_to_repo\" is not a valid path to a repo"
end

set -x board_name (git -C "$path_to_repo" config --local --get jira.board 2>/dev/null)

# return early if we couldn't retrieve a board name
# this checks if path is repository, and properly configured
if test $status -ne 0
    __error "Error: \"jira.board\" is not configured."
end

set -x jira_config_path $HOME/.config/.jira/$board_name.yml

# return early if board config doesn't exist
if not test -e "$jira_config_path"
    __error "Error: \"$jira_config_path\" not found"
end

if test "$SENDER" = tmux_session_update
    if test "$session_name" = default
        sketchybar --set "$NAME" drawing=off
    else
        # fetch the latest jira ticket "In Progress"
        set -x ticket (jira --config $jira_config_path issue list --plain --no-headers -a$(jira me) -s"In Progress" | head -1 | awk '{print $2}' | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}')
        sketchybar --set "$NAME" drawing=on icon.drawing=on icon=󰌃 label="$ticket"
    end
end
