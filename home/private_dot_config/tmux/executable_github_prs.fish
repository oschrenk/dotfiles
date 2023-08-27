#!/usr/bin/env fish

########################
# README
########################

# Requirements:
#   - `git`: brew install git
#   - `gh`: brew install gh
#
# Configuration:
#   - gh needs to be authorized
#   - needs to be enabled via `git config --local gh.query [QUERY]
#     with QUERY something like
#      `"is:open is:pr review-requested:oschrenk archived:false"`
#   - optionally can configure how many tickets should be shown (defaults to 3)
#     `git config --local gh.count [COUNT]

# fail early if git not in $PATH
if not type -q "git"
  echo "Error: Could not find \"git\" in \$PATH" >&2
  exit 1
end

# fail early if gh not in $PATH
if not type -q "gh"
  echo "Error: Could not find \"gh\" in \$PATH" >&2
  exit 1
end

# set directory
set -x path_to_repo $argv[1]

# return early if not valid directory
if not test -d "$path_to_repo"
  echo "Error: \"$path_to_repo\" is not a valid path to a repo" >&2
  exit 1
end

# fetch origin url
set -x origin_url (git -C "$path_to_repo" config --get remote.origin.url 2>/dev/null)

# return early if directory is not valid git
if test $status -ne 0
  echo "Error: \"remote.origin.url\" is not configured." >&2
  exit 1
end

set -x gh_query (git -C "$path_to_repo" config --local --get gh.query 2>/dev/null)

# return early if we couldn't retrieve a github cli query
if test $status -ne 0
  echo "Error: \"gh.query\" is not configured." >&2
  exit 1
end

set -x gh_count (git -C "$path_to_repo" config --local --get gh.count 2>/dev/null)

# fall back onto default count of 3
if test $status -ne 0
  set -x gh_count 3
end

# execute
gh pr -R "$origin_url" list --search "$gh_query" --json number | jq -r '.[] | .number = "\(.number)" | .number' | head -$gh_count | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
