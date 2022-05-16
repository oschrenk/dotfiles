function sideload --description "Sideload to Castro"
  yt-dlp --extract-audio --audio-format mp3 -o "/Users/oliver/Library/Mobile Documents/iCloud~co~supertop~castro/Documents/Sideloads/%(title)s.%(ext)s" $argv
end
