function today --description "Show todays date is ISO-8601 format"
  echo $argv | read -l arg

  switch $arg
    case "--dash"
      date +"%Y-%m-%d"
    case ""
      date +"%Y%m%d"
  end
end
