function edit_command --description "Edit the current command in your $EDITOR"
    set -q EDITOR; or return 1
    set -l tmpfile (mktemp -t "edit_command"); or return 1
    commandline > $tmpfile
    eval $EDITOR $tmpfile
    commandline -r -- (cat $tmpfile)
    rm $tmpfile
end
