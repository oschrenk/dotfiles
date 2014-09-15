function o --description "Open file"
  if command which xdg-open 1>/dev/null 2>/dev/null
  # This is linux xdg-open
    command xdg-open $argv
  else
  # OS X
    command open $argv
  end
end

  function oo --description "Open current directory"

  end

else

  if command which open 1>/dev/null 2>/dev/null
    function o --description "Open file"

    end

    function oo --description "Open current directory"
      command open .
    end

  end
end
