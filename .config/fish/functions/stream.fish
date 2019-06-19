function stream --description "Download videostream"
  youtube-dl --hls-use-mpegts $argv
end

