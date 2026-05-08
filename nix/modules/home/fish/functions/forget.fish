function forget
    set -l cmd (commandline | string collect)
    printf "\nDo you want to forget '%s'? [Y/n]\n" $cmd
    switch (read | tr A-Z a-z)
        case n no
            commandline -f repaint
            return
        case y yes ''
            history delete --exact --case-sensitive -- $cmd
            commandline ""
            commandline -f repaint
    end
end
