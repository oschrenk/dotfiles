function schedule --description "Show schedule as tasks"
  function __date
    echo $argv | read -l date
    if test -z "$date"
      day
    else
      day "$date"
    end
  end

  set -l date (__date $argv[1])
  khal --no-color list (day --khal $date) 1d | sed -e 's/^/  ☐ /' | tail -n +2
end
