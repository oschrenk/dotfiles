function next --description "Returns next weekday"
  echo $argv | read -l day
  set -l day (string lower (echo $argv))

  switch day
  case "tom"
    gdate -d "tomorrow" --iso-8601
  case "*"
    if test -z "$day"
      gdate -d "tomorrow" --iso-8601
    else
      if string match -r -q  '^[0-9]+$' $day
        gdate -d "$day days" --iso-8601
      else
        gdate -d "next $day" --iso-8601
      end
    end
  end
end

