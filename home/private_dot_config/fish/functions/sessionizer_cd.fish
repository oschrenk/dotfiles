function sessionizer_cd --description "Browse git projects using sessionizer"
    set -l dir (sessionizer search --print-path)
    if test -n "$dir"
        cd "$dir"
    end
    commandline -f repaint
end
