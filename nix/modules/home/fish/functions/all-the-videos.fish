function all-the-videos --description "Dowloads all youtube videos open in browser"

    for vid in (chrome-cli list links | grep youtube | grep watch | cut -d " " -f2)
        ipad --no-playlist $vid
    end

end
