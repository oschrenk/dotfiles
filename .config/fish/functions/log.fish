function log --description "Create and/or show todays log entry in $EDITOR"
  set -l logfile $LOG_DIR/(today --iso-short).md
  if test -f $logfile
  else
    set -l date (today --pretty)
    echo "# $date" >> $logfile
  end

  if not test -z (echo $argv)
    set -l time (clock)
    echo "* `$time`: $argv" >> $logfile
  else
    eval $EDITOR $logfile
  end

end
