function copy --description "Copy to clipboard"
    if test \( (count $argv) -eq 0 \)
        # `-c k` print first k bytes. if k starts with -, print all but last k bytes
        # this removes newline
        command ghead -c -1 | pbcopy
        echo "Input copied to clipboard"
    else
        echo "Only works with stdin"
    end
end
