function g
    if not test -z (echo $argv)
        git $argv
    else
        git status
    end
end
