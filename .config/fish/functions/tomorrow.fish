function tomorrow --description "Show tomorrow's date"
  echo $argv | read -l flag

  set -l tomorrow (expr (date +%s) + 86400)

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

  switch $flag
    case "--long"
      set -l suffix (__daySuffix (date +"%d"))
      date -r $tomorrow +"%A,%_d$suffix %B %Y"
    case "--dash"
      date -r $tomorrow +"%Y-%m-%d"
    case ""
      date -r $tomorrow +"%Y%m%d"
  end
end
