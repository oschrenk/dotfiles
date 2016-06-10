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
      "st"
    case "2"
      "nd"
    case "3"
      "rd"
    case "21"
      "st"
    case "22"
      "nd"
    case "23"
      "rd"
    case "31"
      "st"
    case "*"
      echo "th"
    end
end

