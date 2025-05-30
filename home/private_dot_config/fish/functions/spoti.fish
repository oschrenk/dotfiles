function spotifish --description "control spotify from your fish shell"

    function __spoti_usage
        echo "Usage:"
        echo ""
        echo "  spotifish <COMMAND> [OPTIONS]"
        echo ""
        echo "Commands:"
        echo ""
        echo "  play                         # Resume playback where Spotify last left off."
        echo "  play [song name]             # Finds a song by name and plays it."
        echo "  play album [album name]      # Finds an album by name and plays it."
        echo "  play artist [artist name]    # Finds an artist by name and plays it."
        echo "  play list [playlist name]    # Finds a playlist by name and plays it."
        echo
        echo "  next                         # Skips to the next song in a playlist."
        echo "  prev                         # Returns to the previous song in a playlist."
        echo "  pos [time]                   # Jump to a time (in secs) in the current song."
        echo "  pause                        # Pauses Spotify playback."
        echo "  quit                         # Stops playback and quits Spotify."
        echo
        echo "  vol up                       # Increases the volume by 10%."
        echo "  vol down                     # Decreases the volume by 10%."
        echo "  vol [amount]                 # Sets the volume to an amount between 0 and 100."
        echo "  vol show                     # The current Spotify volume from 0 and 100."
        echo
        echo "  status                       # The play status, including the current song."
        echo "  share                        # Copies the current song URL to the clipboard."
        echo
        echo "  toggle shuffle               # Toggle shuffle playback mode."
        echo "  toggle repeat                # Toggle repeat playback mode."
    end

    function __spoti_cecho
        set -l bold (tput bold)
        set -l green (tput setaf 2)
        set -l reset (tput sgr0)
        echo $bold$green"$argv"$reset
    end

    function __spoti_tell
        osascript -e "tell application \"Spotify\" to $argv"
    end

    function __spoti_state
        __spoti_tell "player state as string"
    end

    function __spoti_status
        set -l state (__spoti_state)
        __spoti_cecho "Spotify is currently $state."
        if [ $state = playing ]
            set -l artist (__spoti_tell "artist of current track as string")
            set -l album (__spoti_tell "album of current track as string")
            set -l track (__spoti_tell "name of current track as string")
            set -l duration (__spoti_tell "duration of current track as string")
            set -l duration (echo "scale=2; $duration / 60 / 1000" | bc)
            set -l position (__spoti_tell "player position as string" | tr ',' '.')
            set -l position (echo "scale=2; $position / 60" | bc | awk '{printf "%0.2f", $0}')
            echo -e "Artist: $artist\nAlbum: $album\nTrack: $track \nPosition: $position / $duration"
        end
    end

    function __spoti_play
        __spoti_cecho "Playing Spotify."
        __spoti_tell play
    end

    function __spoti_pause
        if [ __spoti_state = playing ]
            __spoti_cecho "Pausing Spotify."
        else
            __spoti_cecho "Playing Spotify."
        end
        __spoti_tell playpause
    end

    function __spoti_quit
        __spoti_cecho "Quitting Spotify."
        __spoti_tell quit
    end

    function __spoti_next
        __spoti_cecho "Going to next track."
        __spoti_tell "next track"
        __spoti_status
    end

    function __spoti_prev
        __spoti_cecho "Going to previous track."
        __spoti_tell "previous track"
        __spoti_status
    end

    function __spoti_volume
        __spoti_tell "sound volume as integer"
    end

    function __spoti_vol -a subcommand
        set -l volume (__spoti_volume)
        switch $subcommand
            case show
                __spoti_cecho "Current Spotify volume level is $volume."
            case up
                if [ $volume -le 90 ]
                    # FIXME should be +10 but then does actually +9
                    set -l volume (math -s0 "$volume+11")
                    __spoti_cecho "Increasing Spotify volume to $volume."
                    __spoti_tell "set sound volume to $volume"
                else
                    set -l volume 100
                    __spoti_cecho "Spotify volume level is at max."
                    __spoti_tell "set sound volume to $volume"
                end
            case down
                if [ $volume -ge 10 ]
                    # FIXME should be -10 but then does actually -11
                    set -l volume (math -s0 "$volume - 9")
                    __spoti_cecho "Decreasing Spotify volume to $volume."
                    __spoti_tell "set sound volume to $volume"
                else
                    set -l volume 0
                    __spoti_cecho "Spotify volume level is at min"
                    __spoti_tell "set sound volume to $volume"
                end
            case ""
                set -l volume (__spoti_volume)
                __spoti_cecho "Current Spotify volume level is $volume."
            case '*'
                if [ $subcommand -ge 0 ]
                    __spoti_cecho "Setting Spotify volume to $subcommand"
                    __spoti_tell "set sound volume to $subcommand"
                end
        end
    end

    function __spoti_share
        # extract id from spotify:track:123456789abcdef
        set -l spotify_id (__spoti_tell "spotify url of current track" | cut -d: -f3)
        set -l url (echo "http://open.spotify.com/track/$spotify_id")
        __spoti_cecho "Share URL: $url"
        echo -n "$url" | pbcopy
    end

    function __spoti_toggle -a target
        switch $target
            case shuffle
                __spoti_tell "set shuffling to not shuffling"
                set -l current (__spoti_tell "shuffling")
                __spoti_cecho "Spotify shuffling set to: $current"
            case repeat
                __spoti_tell "set repeating to not repeating"
                set -l current (__spoti_tell "repeating")
                __spoti_cecho "Spotify repeating set to: $current"
        end
    end

    function __spoti_fetch_pattern -a type
        switch $type
            case playlist
                echo 'spotify:user:[a-zA-Z0-9_]+:playlist:[a-zA-Z0-9]+'
            case '*'
                echo "spotify:$type:[a-zA-Z0-9]+"
        end
    end

    function __spoti_fetch_play_uri -a count type query
        set -l spotify_search_api "https://api.spotify.com/v1/search"
        set -l pattern (__spoti_fetch_pattern $type)

        curl -s -G $spotify_search_api --data-urlencode "q=$query" -d "type=$type&limit=1&offset=0" -H "Accept: application/json" | grep -E -o "$pattern" -m 1
    end

    function __spoti_play_uri
        __spoti_tell "play track \"$argv\""
    end

    function __spoti_play_track
        set -l query (echo $argv)

        set -l uri (__spoti_fetch_play_uri 1 track $query)
        __spoti_cecho "Searching track for $query"

        __spoti_play_uri $uri
        __spoti_cecho "Playing ($query Search) -> Spotify URL: $uri"
    end

    function __spoti_play_album
        set -l query (echo $argv)

        set -l uri (__spoti_fetch_play_uri 1 album $query)

        __spoti_cecho "Searching album for $query"

        __spoti_play_uri $uri
        __spoti_cecho "Playing ($query Search) -> Spotify URL: $uri"
    end

    function __spoti_play_artist
        set -l query (echo $argv)

        set -l uri (__spoti_fetch_play_uri 1 artist $query)
        __spoti_cecho "Searching artist for $query"

        __spoti_play_uri $uri
        __spoti_cecho "Playing ($query Search) -> Spotify URL: $uri"
    end

    function __spoti_play_list
        set -l query (echo $argv)

        set -l uri (__spoti_fetch_play_uri 1 playlist $query)
        __spoti_cecho "Searching list for $query"

        __spoti_play_uri $uri
        __spoti_cecho "Playing ($query Search) -> Spotify URL: $uri"
    end

    # default settings
    # ----------------------------------------

    ## no less than 1 args
    if test (count $argv) -lt 1
        __spoti_usage
        return
    end

    echo $argv | read -l subcommand arg1 args

    switch $subcommand
        case status
            __spoti_status
        case play
            switch $arg1
                case track
                    __spoti_play_track $args
                case album
                    __spoti_play_album $args
                case artist
                    __spoti_play_artist $args
                case list
                    __spoti_play_list $args
                case ""
                    __spoti_play
                case '*'
                    __spoti_play_track $argv[2..-1]
            end
        case pause
            __spoti_pause
        case next
            __spoti_next
        case prev
            __spoti_prev
        case vol
            __spoti_vol $arg1
        case share
            __spoti_share
        case toggle
            __spoti_toggle $arg1
        case '*'
            __spoti_usage
    end

end
