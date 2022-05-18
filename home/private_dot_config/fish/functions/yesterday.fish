function yesterday --description "Show yesterdays date is ISO-8601 format"
  echo $argv | read -l flag
  set -l date (next -1)
  if test -z "$flag"
    day "$date"
  else
    day "$flag" "$date"
  end
end
