
# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
for file in ~/.{path,aliases,bash_prompt,exports,functions}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

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
# `no_empty_cmd_completion` Attempt to search the PATH for possible completions when completion is attempted on an empty line.
# `checkwinsize` checks the window size after each command and, if necessary, updates the values of LINES and COLUMNS
for option in autocd cdspell cmdhist dirspell globstar histappend nocaseglob no_empty_cmd_completion checkwinsize; do
  tmp="$(shopt -q "$option" 2>&1 > /dev/null | grep "invalid shell option name")"
  if [ '' == "$tmp" ]; then
    shopt -s "$option"
  fi
done

# If possible, add tab completion for many more commands
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
elif [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi

# z s the new j, https://github.com/rupa/z
if command -v brew >/dev/null && [ -f  $(brew --prefix)/etc/profile.d/z.sh ]; then
  .  $(brew --prefix)/etc/profile.d/z.sh
fi

# enable jenv shims
eval "$(jenv init -)"