#
# Make ls use colors if we are on a system that supports this
#
if command which xdg-open 1>/dev/null 2>/dev/null
  # This is linux xdg-open
  function o --description "Open file"
    command xdg-open $argv
  end

  function oo --description "Open current directory"
    command xdg-open .
  end

else
  # OS X
  if command which open 1>/dev/null 2>/dev/null
    function o --description "Open file"
      command open $argv
    end

    function oo --description "Open current directory"
      command open .
    end

  end
end
