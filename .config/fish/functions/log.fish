function log --description "Create and/or show todays log entry in Sublime"
  touch $HOME/Documents/logs/(today).md

  if not test -z (echo $argv)
    echo -e "" >> $HOME/Documents/logs/(today).md
    echo (time) >> $HOME/Documents/logs/(today).md
    echo -e "-----" >> $HOME/Documents/logs/(today).md
    echo $argv >> $HOME/Documents/logs/(today).md
  else
    sl $HOME/Documents/logs/(today).md
  end

end
