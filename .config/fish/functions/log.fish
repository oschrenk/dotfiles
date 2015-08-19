function log --description "Create and/or show todays log entry in $EDITOR"
  touch $HOME/Documents/logs/(today).md

  if not test -z (echo $argv)
    echo -e "" >> $HOME/Documents/logs/(today).md
    echo (time) >> $HOME/Documents/logs/(today).md
    echo -e "-----" >> $HOME/Documents/logs/(today).md
    echo $argv >> $HOME/Documents/logs/(today).md
  else
    eval $EDITOR $HOME/Documents/logs/(today).md
  end

end
