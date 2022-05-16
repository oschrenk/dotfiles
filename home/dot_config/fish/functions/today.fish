function today --description "Show todays date"
  echo $argv | read -l flag
  set -l date (next 0)
  if test -z "$flag"
    day "$date"
  else
    day "$flag" "$date"
  end
end

