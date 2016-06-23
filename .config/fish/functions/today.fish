function today --description "Show todays date"
  echo $argv | read -l arg

  switch $arg
    case "--long"
      set -l suffix (__daySuffix (date +"%d"))
      date +"%A, %d$suffix %B %Y"
    case "--dash"
      date +"%Y-%m-%d"
    case ""
      date +"%Y%m%d"
  end
end

function __daySuffix
  switch $argv[1]
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

