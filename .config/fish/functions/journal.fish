function journal --description "Create and show a journal entry in $EDITOR"
  function __date
    echo $argv | read -l date
    if test -z "$date"
      day
    else
      day "$date"
    end
  end

  set -l date (__date $argv[1])

  set -l logfile $JOURNAL_DIR/(day --iso-short $date).md
  # Create file if it doesn't exist
  if not test -f $logfile
    set -l pretty_date (day --pretty $date)
    # date as heading
    echo "# $pretty_date" >> $logfile
    # empty line
    echo "" >> $logfile
    # schedule
    echo "Events.schedule" >> $logfile
    schedule $date >> $logfile
    # empty line
    echo "" >> $logfile
    # template
    journal-template $date >> $logfile
  end

  eval "$EDITOR -c 'Goyo' $logfile"

end
