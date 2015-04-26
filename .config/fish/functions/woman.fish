function __woman_help
  echo "Unrecognized command."
  echo ""
  echo "Usage: woman <COMMAND>"
  echo ""
  echo "Examples:"
  echo ""
  echo " woman tar"
  echo " woman ls"
  echo ""
end

function woman --description  "a companion for man, showing examples"

  # woman default settings
  # ----------------------------------------
  set -l woman_home $HOME/.woman

  if not test -d $woman_home
    echo "No $woman_home directory found. Exiting."
    return
  end

  if test \( (count $argv) -ne 1 \)
    __woman_help
    return
  end

  echo $argv | read -l topic

  set -l file $woman_home/$topic.md
  if test -e $file
    cat $file
  else echo "No womanual entry for $topic"
  end
end
