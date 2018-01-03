function plan  --description "Create and show tomorrow's journal entry in $EDITOR"
  set -l date (next 1)
  journal "$date"
end
