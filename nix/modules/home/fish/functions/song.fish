function song --description "Download song"
    yt-dlp -f ba[ext=m4a] $argv
end
