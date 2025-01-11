function md --description "Create markdown links"
    set url "$argv[1]"

    if test -z "$url"
        set url (pbpaste | string trim)
    end

    if not string match -q "*youtube.com*" "$url"
        set shortened (echo "$url" | string shorten --char="..." --max 20)
        echo "Error: Unsupported url `$shortened`" 1>&2
        return
    end

    set temp_file (mktemp)

    yt-dlp --dump-json "$url" | jq . >"$temp_file"

    set title (jq -r '.title' "$temp_file")
    set channel (jq -r '.channel' "$temp_file")
    set webpage_url (jq -r '.webpage_url' "$temp_file")
    set duration (jq -r '.duration' "$temp_file")

    set hours (math --scale 0 "$duration / 3600")
    set seconds_left_after_hour (math "$duration % 3600")
    set minutes (math "round ($seconds_left_after_hour / 60)")

    if [ $hours -ge 1 ]
        set duration_string (echo "$hours"h"$minutes"m)
    else
        set duration_string (echo "$minutes"m)
    end

    echo '['"$channel"- "$title"']('"$webpage_url"')' '#source/youtube #length/'"$duration_string #watch/todo"

    rm $temp_file
end
