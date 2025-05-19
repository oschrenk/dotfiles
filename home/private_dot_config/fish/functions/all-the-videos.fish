function all-the-videos --description "Dowloads all youtube videos open in browser"

    export CHROME_BUNDLE_IDENTIFIER="company.thebrowser.Browser"

    for vid in (chrome-cli list links | grep youtube | grep watch | cut -d " " -f2)
        pad --no-playlist $vid
    end

end
