function slow-electron --description "Slow electron"

    for f in /Applications/*/Contents/Frameworks/Electron\ Framework.framework/Versions/A/Electron\ Framework
        set app (string replace -r '^/Applications/' '' $f)
        set app (string replace -r '/Contents/.*' '' $app)

        # Get Electron version
        set ev (rg -a -m1 -o -r '$1' 'Chrome/.*Electron/([0-9]+(\.[0-9]+){1,3})' -- "$f")
        if test -z "$ev"
            set ev (rg -a -m1 -o -r '$1' 'Electron/([0-9]+(\.[0-9]+){1,3})' -- "$f")
        end

        # Ripgrep the binary for _cornerMask
        if rg -a -q -F _cornerMask -- "$f"
            echo -e "\033[31m❌ $app \033[2m(Electron $ev)\033[0m"
        else
            echo -e "\033[32m✅ $app \033[2m(Electron $ev)\033[0m"
        end
    end
end
