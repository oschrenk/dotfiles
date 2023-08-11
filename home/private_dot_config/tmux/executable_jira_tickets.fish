#!/usr/bin/env fish

set -x path_to_repo $argv[1]

# return early if no path
if test -z "$path_to_repo"
  exit 0
end

set -x board_name (git -C "$path_to_repo" config --local --get jira.board 2>/dev/null)

# return early if directory is not valid git
if test $status -ne 0
  exit 0
end

set -x jira_config_path $HOME/.config/.jira/$board_name.yml

# TODO the state might depend on the actual board
jira --config $jira_config_path issue list --plain --no-headers -a$(jira me) -s"In Progress" | head -3 | awk '{print $2}' | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
