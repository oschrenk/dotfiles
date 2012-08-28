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