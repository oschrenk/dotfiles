function pad --description "Download videos for iPad"
    yt-dlp -f bestvideo[height<=720]+bestaudio/best[height<=720] $argv
end
