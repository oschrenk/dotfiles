# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,aliases,bash_prompt,functions,github}; do
    [ -r "$file" ] && source "$file"
done
unset file

GREP_OPTIONS=
for PATTERN in .cvs .git .hg .svn; do
    GREP_OPTIONS="$GREP_OPTIONS --exclude-dir=$PATTERN"
done
export GREP_OPTIONS

export LESS="-F -X -R"

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

# Enable some Bash features when possible:
# `autocd`. Since 4.0-alpha. e.g. `**/qux` will enter `./foo/bar/baz/qux`
# `cdspell` Minor spelling errors of a directory in a `cd`  will be corrected
# `cmdhist Save multi-line commands in history as single line
# `dirspell` Since 4.0-alpha. Bash will perform spelling corrections on directory names to match a glob.
# `globstar`.Since 4.0-alpha. Recursive globbing with `**` is enabled
# `histappend` Append to the same history file when using multiple terminals
# `nocaseglob` When typing filename and Tab to autocomplete, do a case-insensitive search.
# `no_empty_cmd_completion` Attempt to search the PATH for possible completions when completion is attempted on an empty lin.
for option in autocd cdspell cmdhist dirspell globstar histappend nocaseglob no_empty_cmd_completion; do
  tmp="$(shopt -q "$option" 2>&1 > /dev/null | grep "invalid shell option name")"
  if [ '' == "$tmp" ]; then
    shopt -s "$option"
  fi
done