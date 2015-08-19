function yesterday --description "Show yesterdays date is ISO-8601 format"
  echo $argv | read -l flag

  set -l yesterday (expr (date +%s) - 86400)

  if test -z $flag
    set format '+%Y%m%d'
  end

  switch $flag
    case "--long"
      set format '+%A, %B %d %Y '

  end

  date -r $yesterday $format
end
