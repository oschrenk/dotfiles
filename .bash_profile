# my paths
if [ -f ~/.paths ]; then
  . ~/.paths
fi

# set defunkt/hub environment variables
# not included in dotfiles repo because of security reasons
# export GITHUB_USER=<username>
# export GITHUB_TOKEN=<token>
if [ -f ~/.github ]; then
  . ~/.github
fi

# Alias definitions.
if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

GREP_OPTIONS=
for PATTERN in .cvs .git .hg .svn; do
    GREP_OPTIONS="$GREP_OPTIONS --exclude-dir=$PATTERN"
done
export GREP_OPTIONS

export LESS="-F -X -R"

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

# show current git branch in prompt
function parse_git_branch_and_add_brackets {
git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \[\1\]/'
}
PS1="\h:\W \u\[\033[0;32m\]\$(parse_git_branch_and_add_brackets) \[\033[0m\]\$ "

# cdf: cd's to frontmost window of Finder
# source: http://asktherelic.com/2009/01/31/osx-terminal-and-finder-integration/
cdf ()
{
    currFolderPath=$( /usr/bin/osascript <<"    EOT"
        tell application "Finder"
            try
                set currFolder to (folder of the front window as alias)
            on error
                set currFolder to (path to desktop folder as alias)
            end try
            POSIX path of currFolder
        end tell
    EOT
    )
    echo "cd to "$currFolderPath""
    cd "$currFolderPath"
}

