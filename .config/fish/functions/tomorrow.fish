function tomorrow --description "Show tomorrow's date"
  echo $argv | read -l flag
  set -l date (next 1)
  if test -z "$flag"
    day "$date"
  else
    day "$flag" "$date"
  end
end
