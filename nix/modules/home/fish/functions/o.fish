function o --description "Open file"
    if command which xdg-open 1>/dev/null 2>/dev/null
        # This is linux xdg-open
        command xdg-open $argv
    else
        # macOS
        command open $argv
    end
end
