# icloud-to-nas — Migrate iCloud Drive files to NAS one file at a time.
#
# Downloads from iCloud → copies to NAS via SMB → evicts local copy.
# Keeps disk usage minimal by processing one file at a time.
# Tracks progress so you can resume after interruptions (Ctrl+C safe).
#
# Prerequisites:
#   1. NAS share mounted (e.g., mount_smbfs //oliver@<unas-ip>/Media /Volumes/Media)
#   2. brctl available (ships with macOS)
#
# Usage:
#   icloud-to-nas "Watch/Movies" "/Volumes/Media/Watch/Movies"
#   icloud-to-nas "Watch/Series/Andor" "/Volumes/Media/Watch/Series/Andor"
#   icloud-to-nas --dry-run "Watch" "/Volumes/Media/Watch"

function _itn_log -a msg
    printf "%s[%s]%s %s\n" (set_color green) (date +%H:%M:%S) (set_color normal) "$msg"
end

function _itn_warn -a msg
    printf "%s[%s] WARN:%s %s\n" (set_color yellow) (date +%H:%M:%S) (set_color normal) "$msg"
end

function _itn_err -a msg
    printf "%s[%s] ERROR:%s %s\n" (set_color red) (date +%H:%M:%S) (set_color normal) "$msg" >&2
end

function _itn_human_size -a bytes
    if test $bytes -ge 1073741824
        printf "%.1f GB" (math "$bytes / 1073741824")
    else if test $bytes -ge 1048576
        printf "%.1f MB" (math "$bytes / 1048576")
    else if test $bytes -ge 1024
        printf "%.0f KB" (math "$bytes / 1024")
    else
        printf "%s B" $bytes
    end
end

function _itn_free_space_gb
    df -g "$HOME" | awk 'NR==2 {print $4}'
end

function _itn_file_size_bytes -a file
    stat -f%z "$file" 2>/dev/null; or echo 0
end

function _itn_is_downloaded -a file
    set -l blocks (stat -f%b "$file" 2>/dev/null; or echo 0)
    test "$blocks" -gt 0
end

function _itn_is_migrated -a file progress_log
    grep -qFx "$file" "$progress_log" 2>/dev/null
end

function _itn_mark_migrated -a file progress_log
    echo "$file" >>"$progress_log"
end

function _itn_download_and_wait -a file size poll_interval max_timeout
    if _itn_is_downloaded "$file"
        return 0
    end

    brctl download "$file" 2>/dev/null; or true

    # Timeout scales with file size: 60s base + 1s per 2 MB, capped
    set -l timeout (math "60 + $size / 2097152")
    if test $timeout -gt $max_timeout
        set timeout $max_timeout
    end

    set -l elapsed 0
    while not _itn_is_downloaded "$file"
        sleep $poll_interval
        set elapsed (math "$elapsed + $poll_interval")
        if test $elapsed -ge $timeout
            _itn_err "Timeout after {$elapsed}s waiting for download"
            return 1
        end
        printf "\r  %siCloud → disk... %ds%s  " (set_color brblack) $elapsed (set_color normal)
    end
    printf "\r                              \r"
    return 0
end

# Args: src dst dry_run min_free_gb progress_log poll_interval max_timeout
function _itn_process_file
    set -l src $argv[1]
    set -l dst $argv[2]
    set -l dry_run $argv[3]
    set -l min_free_gb $argv[4]
    set -l progress_log $argv[5]
    set -l poll_interval $argv[6]
    set -l max_timeout $argv[7]

    set -l filename (basename "$src")
    set -l size (_itn_file_size_bytes "$src")
    set -l human (_itn_human_size $size)

    if _itn_is_migrated "$src" "$progress_log"
        _itn_log "  "(set_color brblack)"skip"(set_color normal)" (already done)"
        return 0
    end

    # If destination already exists with correct size, just log and skip
    if test -f "$dst"
        set -l dst_size (_itn_file_size_bytes "$dst")
        if test "$dst_size" = "$size"
            _itn_log "  "(set_color brblack)"skip"(set_color normal)" (already on NAS)"
            _itn_mark_migrated "$src" "$progress_log"
            return 0
        end
    end

    if test "$dry_run" = true
        _itn_log "  "(set_color yellow)"dry-run"(set_color normal)" $human"
        return 0
    end

    # Check free space
    set -l free (_itn_free_space_gb)
    set -l needed_gb (math "floor($size / 1073741824) + 2")
    if test $free -lt (math "$min_free_gb + $needed_gb")
        _itn_err "Low disk space: {$free} GB free, need ~{$needed_gb} GB + {$min_free_gb} GB buffer"
        _itn_err "Waiting 30s for evictions to clear, then retrying..."
        sleep 30
        set free (_itn_free_space_gb)
        if test $free -lt (math "$min_free_gb + $needed_gb")
            _itn_err "Still not enough space ({$free} GB). Stopping."
            return 1
        end
    end

    # Step 1: iCloud → local disk
    _itn_log "  "(set_color blue)"↓"(set_color normal)" iCloud → disk ($human)"
    if not _itn_download_and_wait "$src" $size $poll_interval $max_timeout
        _itn_err "iCloud download failed: $filename"
        return 1
    end

    # Step 2: local disk → NAS
    set -l dst_dir (dirname "$dst")
    mkdir -p "$dst_dir"
    _itn_log "  "(set_color blue)"↑"(set_color normal)" disk → NAS"
    if not rsync -aX --info=progress2 "$src" "$dst"
        _itn_err "NAS upload failed: $filename"
        return 1
    end

    # Step 3: verify
    set -l dst_size (_itn_file_size_bytes "$dst")
    if test "$dst_size" != "$size"
        _itn_err "Size mismatch! source=$size destination=$dst_size"
        rm -f "$dst"
        return 1
    end

    # Step 4: evict local copy
    brctl evict "$src" 2>/dev/null; or true
    _itn_log "  "(set_color green)"✓"(set_color normal)" evicted local copy"

    _itn_mark_migrated "$src" "$progress_log"
    return 0
end

function icloud-to-nas
    set -l ICLOUD_BASE "$HOME/Library/Mobile Documents/com~apple~CloudDocs"
    set -l NAS_BASE /Volumes/Media
    set -l MIN_FREE_GB 10
    set -l POLL_INTERVAL 3
    set -l MAX_POLL_TIMEOUT 7200
    set -l DRY_RUN false
    set -l PROGRESS_LOG ""

    # --- Argument parsing ---

    set -l positional
    set -l i 1

    while test $i -le (count $argv)
        switch $argv[$i]
            case --nas-base
                set i (math "$i + 1")
                set NAS_BASE $argv[$i]
            case --progress
                set i (math "$i + 1")
                set PROGRESS_LOG $argv[$i]
            case --min-free
                set i (math "$i + 1")
                set MIN_FREE_GB $argv[$i]
            case --dry-run
                set DRY_RUN true
            case -h --help
                echo "Usage: icloud-to-nas [OPTIONS] <source> [destination]"
                echo ""
                echo "Migrate iCloud Drive files to a mounted NAS share, one at a time."
                echo ""
                echo "Arguments:"
                echo "  source        Path relative to iCloud Drive (e.g., \"Watch/Movies\")"
                echo "  destination   Absolute path on mounted NAS (default: $NAS_BASE/<source>)"
                echo ""
                echo "Options:"
                echo "  --nas-base PATH  Base NAS mount point (default: $NAS_BASE)"
                echo "  --progress FILE  Custom progress log path (default: <destination>/.migration.log)"
                echo "  --min-free N     Minimum free GB to keep on local disk (default: 10)"
                echo "  --dry-run        Show what would happen without doing anything"
                echo "  -h, --help       Show this help"
                echo ""
                echo "Examples:"
                echo "  icloud-to-nas \"Watch/Movies\""
                echo "  icloud-to-nas --dry-run \"Watch/Series\""
                echo "  icloud-to-nas \"Watch/Series/Andor\""
                echo "  icloud-to-nas --nas-base /Volumes/Documents \"Calibre\""
                return 0
            case '-*'
                _itn_err "Unknown option: $argv[$i]"
                return 1
            case '*'
                set -a positional $argv[$i]
        end
        set i (math "$i + 1")
    end

    if test (count $positional) -lt 1 -o (count $positional) -gt 2
        echo "Usage: icloud-to-nas [OPTIONS] <source> [destination]"
        echo "Run icloud-to-nas --help for details."
        return 1
    end

    set -l source_rel $positional[1]
    set -l nas_dest
    if test (count $positional) -eq 2
        set nas_dest $positional[2]
    else
        set nas_dest "$NAS_BASE/$source_rel"
    end
    set -l source_abs "$ICLOUD_BASE/$source_rel"

    if not test -e "$source_abs"
        _itn_err "Source not found: $source_abs"
        return 1
    end

    if not test -d "$nas_dest"
        mkdir -p "$nas_dest" 2>/dev/null; or begin
            _itn_err "Cannot access NAS destination: $nas_dest"
            _itn_err "Is the share mounted? Example:"
            _itn_err "  mkdir -p /Volumes/Media"
            _itn_err "  mount_smbfs //oliver@<unas-ip>/Media /Volumes/Media"
            return 1
        end
    end

    if test -z "$PROGRESS_LOG"
        set PROGRESS_LOG "$NAS_BASE/.migration.log"
    end
    touch "$PROGRESS_LOG"

    # Build file list
    set -l file_list (mktemp)
    find "$source_abs" -type f ! -name '.DS_Store' ! -name '.*' | sort >"$file_list"

    set -l total_files (wc -l <"$file_list" | string trim)
    set -l already_done (wc -l <"$PROGRESS_LOG" 2>/dev/null | string trim)
    set -l total_size (xargs -I{} stat -f%z {} <"$file_list" 2>/dev/null | awk '{s+=$1} END {printf "%.1f", s/1073741824}')

    echo ""
    _itn_log "Source:       $source_rel"
    _itn_log "Destination:  $nas_dest"
    _itn_log "Files:        $total_files ({$total_size} GB total)"
    _itn_log "Already done: $already_done"
    _itn_log "Free space:   "(_itn_free_space_gb)" GB (keeping {$MIN_FREE_GB} GB free)"
    if test "$DRY_RUN" = true
        _itn_log (set_color yellow)"DRY RUN — no files will be modified"(set_color normal)
    end
    echo ""

    # Ctrl+C handling: set flag so the loop can exit cleanly
    set -l interrupted false
    function _itn_on_sigint --on-signal INT
        set interrupted true
    end

    set -l count 0
    set -l migrated 0
    set -l skipped 0
    set -l failed 0

    while read -l file
        if test "$interrupted" = true
            _itn_warn "Interrupted — stopping after current file"
            break
        end

        set count (math "$count + 1")
        set -l rel_path (string replace "$source_abs/" "" "$file")

        _itn_log "[$count/$total_files] $rel_path"

        if _itn_process_file "$file" "$nas_dest/$rel_path" $DRY_RUN $MIN_FREE_GB "$PROGRESS_LOG" $POLL_INTERVAL $MAX_POLL_TIMEOUT
            if _itn_is_migrated "$file" "$PROGRESS_LOG"
                if test $count -gt $already_done
                    set migrated (math "$migrated + 1")
                else
                    set skipped (math "$skipped + 1")
                end
            end
        else
            set failed (math "$failed + 1")
            _itn_warn "Failed — continuing with next file"
        end
    end <"$file_list"

    functions -e _itn_on_sigint
    rm -f "$file_list"

    echo ""
    _itn_log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    _itn_log "Complete: $migrated migrated, $skipped skipped, $failed failed"
    _itn_log "Free space: "(_itn_free_space_gb)" GB"
    if test $failed -gt 0
        _itn_warn "Re-run the same command to retry failed files"
    end
    if test "$interrupted" = true
        _itn_warn "Interrupted early — re-run to continue"
    end
end
