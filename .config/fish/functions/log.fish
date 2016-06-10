function log --description "Create and/or show todays log entry in $EDITOR"
  set -l logfile $LOG_DIR/(today).md
  if test -f $logfile
  else
    set -l date (today --long)
    echo "# $date" >> $logfile
  end

  if not test -z (echo $argv)
    set -l time (time)
    echo "* `$time`: $argv" >> $logfile
  else
    eval $EDITOR $logfile
  end

end
