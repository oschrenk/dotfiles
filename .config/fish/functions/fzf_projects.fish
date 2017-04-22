function fzf_projects --description "Browse git projects using fzf"
  set -l base_dir $HOME/Projects
  set -l length (math (string length $base_dir) + 2)
  set -q FZF_PROJECT_COMMAND; or set -l FZF_PROJECT_COMMAND "
  find $base_dir -type d -name ".git" -maxdepth 4 | rev | cut -c6- | rev | cut -c$length-"
  # Fish hangs if the command before pipe redirects (2> /dev/null)
  eval "$FZF_PROJECT_COMMAND | "(__fzfcmd)" +m $FZF_PROJECT_OPTS > $TMPDIR/fzf.result"
  [ (cat $TMPDIR/fzf.result | wc -l) -gt 0 ]
  and cd $base_dir/(cat $TMPDIR/fzf.result)
  commandline -f repaint
  rm -f $TMPDIR/fzf.result
end
