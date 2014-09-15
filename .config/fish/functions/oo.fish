function oo --description "Open current directory"
  if command which xdg-open 1>/dev/null 2>/dev/null
  # This is linux xdg-open
    command xdg-open .
  else
  # OS X
    command open .
  end
end
