function plan  --description "Create and show tomorrow's journal entry in $EDITOR"

  set -l logfile $JOURNAL_DIR/(tomorrow).md
  # Create file if it doesn't exist
  if not test -f $logfile
    set -l date (tomorrow --long)
    echo "# $date" >> $logfile
    # use template
    echo "" >> $logfile
    cat $HOME/.config/journal/template.md >> $logfile
  end

  eval "$EDITOR -c 'Goyo' $logfile"

end