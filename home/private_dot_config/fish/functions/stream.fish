function stream --description "Download videostream"
  yt-dlp --hls-use-mpegts $argv
end

