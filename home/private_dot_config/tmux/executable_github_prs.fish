#!/usr/bin/env fish

set -x path_to_repo $argv[1]

# return early if no path
if test -z "$path_to_repo"
  exit 0
end

set -x origin_url (git -C "$path_to_repo" config --get remote.origin.url 2>/dev/null)

# return early if directory is not valid git
if test $status -ne 0
  exit 0
end

set -x repo (echo $origin_url | cut -d ":" -f 2 | cut -d "." -f 1)

gh pr -R $repo list --search "is:open is:pr review-requested:oschrenk archived:false" --json number | jq -r '.[] | .number = "\(.number)" | .number' | head -3 | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
