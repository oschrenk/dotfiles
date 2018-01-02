function day --description "Show formatted date"

  function __print
    echo $argv | read -l flag date
    switch $flag
      case "--pretty"
        set -l suffix (__daySuffix (gdate --date="$date" "+%e"))
        gdate --date="$date" "+%A,%e$suffix %B %Y"
      case "--iso-short"
        # re-parse date for validation
        gdate --date="$date" "+%Y%m%d"
      case "--iso-long"
        # re-parse date for validation
        gdate --date="$date" "+%Y-%m-%d"
    case "*"
       echo "Unknown flag"
    end
  end

  function __daySuffix
    set -l day (string trim $argv[1])
    switch $day
    case "1"
      echo "st"
    case "2"
      echo "nd"
    case "3"
      echo "rd"
    case "21"
      echo "st"
    case "22"
      echo "nd"
    case "23"
      echo "rd"
    case "31"
      echo "st"
    case "*"
      echo "th"
    end
  end

  if test (count $argv) -eq 2
    echo $argv | read -l flag value
    __print $flag $value
  else if test (count $argv) -eq 1
    __print "--iso-long" $argv[1]
  else
    __print "--iso-long" "today"
  end

end

