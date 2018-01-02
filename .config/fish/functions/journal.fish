function journal --description "Create and show todays journal entry in $EDITOR"
  set -l logfile $JOURNAL_DIR/(today).md
  # Create file if it doesn't exist
  if not test -f $logfile
    set -l date (today --long)
    echo "# $date" >> $logfile
    # use template
    echo "" >> $logfile
    cat $HOME/.config/journal/template.md >> $logfile
  end

  eval "$EDITOR -c 'Goyo' $logfile"

end
