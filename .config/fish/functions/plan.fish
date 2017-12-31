function plan  --description "Create and show tomorrow's journal entry in $EDITOR"

  set -l logfile $JOURNAL_DIR/(tomorrow).md
  # Create file if it doesn't exist
  if not test -f $logfile
    set -l date (tomorrow --long)
    echo "# $date" >> $logfile
    # add two empty lines
    echo "" >> $logfile
    echo "" >> $logfile
  end

  # start with Goyo, in insert mode and at and of file
  eval "$EDITOR -c 'Goyo | startinsert' + $logfile"

end
