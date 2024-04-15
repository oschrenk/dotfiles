function urlencode --description urlencode
    if not test -z (echo $argv)
        python -c "import urllib, sys; print urllib.quote(\"$argv\", \"\")"
    else
        python -c "import urllib, sys; print urllib.quote(sys.stdin.read()[0:-1], \"\")"
    end

end
