function journal --description "Create and show todays journal entry in $EDITOR"
  set -l logfile $JOURNAL_DIR/(today).md
  # Create file if it doesn't exist
  if not test -f $logfile
    set -l date (today --long)
    echo "# $date" >> $logfile
    # add two empty lines
    echo "" >> $logfile
    echo "" >> $logfile
  end

  # start with Goyo, in insert mode and at and of file
  eval "$EDITOR -c 'Goyo | startinsert' + $logfile"

end
