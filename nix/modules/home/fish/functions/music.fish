function music --description "Download audio from a URL into ~/Music"
    if test (count $argv) -eq 0
        echo "usage: music <url> [<url>...]" >&2
        return 1
    end

    set -l overall_status 0

    for url in $argv
        # Probe upfront: does this video have chapter markers?
        # Output is the literal "NA" (yt-dlp's null placeholder) when absent.
        set -l chapters (yt-dlp --print "%(chapters)s" --skip-download "$url" 2>/dev/null | head -1)

        if test -z "$chapters" -o "$chapters" = NA
            # No chapters: single file, thumbnail embedded normally.
            yt-dlp \
                -x \
                -f bestaudio \
                --embed-thumbnail \
                --embed-metadata \
                --convert-thumbnails jpg \
                -o "$HOME/Music/%(uploader)s - %(title)s.%(ext)s" \
                "$url"
        else
            # Has chapters: split into a per-video subdir, save the thumbnail
            # as cover.jpg in that subdir (mpd's `albumart` picks it up for
            # every chapter file). We do NOT use --embed-thumbnail here: the
            # embed step injects an mjpeg stream that breaks the subsequent
            # SplitChapters ffmpeg stream-copy with
            #   [opus] Unsupported codec id in stream 1.
            yt-dlp \
                -x \
                -f bestaudio \
                --write-thumbnail \
                --embed-metadata \
                --convert-thumbnails jpg \
                --split-chapters \
                -o "$HOME/Music/%(uploader)s - %(title)s.%(ext)s" \
                -o "thumbnail:$HOME/Music/%(uploader)s - %(title)s/cover.%(ext)s" \
                -o "chapter:$HOME/Music/%(uploader)s - %(title)s/%(section_number)03d - %(section_title)s.%(ext)s" \
                "$url"

            # Delete the full-length file; the chapter subdir is the keeper.
            set -l title (yt-dlp --print "%(uploader)s - %(title)s" --skip-download "$url" 2>/dev/null | head -1)
            if test -n "$title"; and test -d "$HOME/Music/$title"
                rm -f "$HOME/Music/$title.opus"
            end
        end

        test $status -ne 0; and set overall_status $status
    end

    # Refresh mpd's library so rmpc sees the new files. brew's mpd build has
    # FS-watch disabled, so `auto_update yes` is a no-op; manual nudge needed.
    if command -q mpc
        mpc update >/dev/null 2>&1
    end

    return $overall_status
end
