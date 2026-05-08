function sideload --description "Sideload to Castro"
    yt-dlp --extract-audio --audio-format mp3 -o "$HOME/Library/Mobile Documents/iCloud~co~supertop~castro/Documents/Sideloads/%(channel)s - %(title)s.%(ext)s" $argv
end
