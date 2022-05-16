function trim
  echo $argv | sed -e 's/^ *//' -e 's/ *$//'
end
