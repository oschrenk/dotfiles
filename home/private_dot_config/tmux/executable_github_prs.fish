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
#   - needs to be enabled via
#       `git config --local gh.query [QUERY]`
#     with QUERY something like
#       `"is:open is:pr review-requested:oschrenk archived:false"`
#   - optional username to be configured via
#       `git config --local gh.username [NAME]`
#   - optionally can configure how many tickets should be shown (defaults to 3)
#     `git config --local gh.count [COUNT]`

# ---------------------------
# functions
# ---------------------------

function fetch_pr_numbers -a origin_url gh_query gh_count gh_username
    # no   gh_username -> user query as is
    # with gh_username -> additionally filter by request
    #                     person needs to be explicitly invited
    if set -q $gh_username; or not test -e $gh_username
        gh pr -R "$origin_url" list --search "$gh_query" --json reviewRequests,number | jq -r --arg gh_username "$gh_username" '.[] | select (.reviewRequests[].login == $gh_username) | .number' | head -$gh_count | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
    else
        gh pr -R "$origin_url" list --search "$gh_query" --json reviewRequests,number | jq -r '.[] | .number' | head -$gh_count | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
    end
end

# ---------------------------
# guards, requirements
# ---------------------------

# fail early if git not in $PATH
if not type -q git
    echo "Error: Could not find \"git\" in \$PATH" >&2
    exit 1
end

# fail early if gh not in $PATH
if not type -q gh
    echo "Error: Could not find \"gh\" in \$PATH" >&2
    exit 1
end

# ---------------------------
# guards, arguments
# ---------------------------

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

# ---------------------------
# configure
# ---------------------------

set -x gh_query (git -C "$path_to_repo" config --local --get gh.query 2>/dev/null)

# return early if we couldn't retrieve a github cli query
if test $status -ne 0
    echo "Error: \"gh.query\" is not configured." >&2
    exit 1
end

set -x gh_username (git -C "$path_to_repo" config --local --get gh.username 2>/dev/null)

set -x gh_count (git -C "$path_to_repo" config --local --get gh.count 2>/dev/null)

# fall back onto default count of 3
if test $status -ne 0
    set -x gh_count 3
end

# ---------------------------
# execute
# ---------------------------
fetch_pr_numbers $origin_url $gh_query $gh_count $gh_username
