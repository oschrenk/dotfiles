function plan --description "Create and show tomorrow's journal entry in $EDITOR"
  if test (count $argv) -eq 1
    echo $argv | read -l day
    journal (next $day)
  else
    set -l date (next 1)
    journal "$date"
  end
end
