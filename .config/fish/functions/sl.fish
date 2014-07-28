# alias for Sublime
# `sl` with no arguments opens current directory
# otherwise opens the given location

function sl
    if [ (count $argv) -gt 0 ]
        subl $argv
    else
        subl .
    end
end
