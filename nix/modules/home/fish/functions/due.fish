function due --description "Interact with the Due app"
    set -l store "$HOME/Library/Group Containers/5JMF32H3VU.com.phocusllp.duemac.shared/Compact.duecdb"

    switch "$argv[1]"
        case list
            argparse overdue -- $argv[2..]
            or return 2

            if not test -r "$store"
                echo "due: reminder store not found: $store" >&2
                return 1
            end

            set -l overdue 0
            set -ql _flag_overdue; and set overdue 1

            jq -r --argjson overdue $overdue '
                .DUCompactStoreRemindersInJSONFormat
                | sort_by(.d)
                | if $overdue == 1 then map(select(.d < now)) else . end
                | .[]
                | (if .d < now then "[31m" else "" end)
                  + (.d | strflocaltime("%Y-%m-%d %H:%M")) + "  "
                  + (if .rf then "↻ " else "  " end)
                  + .n
                  + (if .d < now then "[0m" else "" end)
            ' "$store"

        case snooze
            set -l duration $argv[2]
            set -l query (string join ' ' $argv[3..])
            if test -z "$duration"; or test -z "$query"
                echo "usage: due snooze <duration> <title>  (duration: 15m, 2h, 1d)" >&2
                return 2
            end

            set -l parts (string match -r '^(\d+)([mhd])$' $duration)
            if test -z "$parts"
                echo "due: invalid duration: $duration (use 15m, 2h, 1d)" >&2
                return 2
            end
            set -l minutes $parts[2]
            switch $parts[3]
                case h
                    set minutes (math "$parts[2] * 60")
                case d
                    set minutes (math "$parts[2] * 1440")
            end

            if not test -r "$store"
                echo "due: reminder store not found: $store" >&2
                return 1
            end

            set -l title (jq -r --arg q "$query" '
                .DUCompactStoreRemindersInJSONFormat
                | map(select(.n | ascii_downcase | contains($q | ascii_downcase)))
                | sort_by(.d)
                | .[0].n // empty
            ' "$store")
            if test -z "$title"
                echo "due: no reminder matching: $query" >&2
                return 1
            end

            # Shortcuts needs a typed file; an extensionless payload arrives as
            # unreadable data and the shortcut prompts instead of running.
            set -l tmp (mktemp)
            set -l payload "$tmp.txt"
            printf '%s|%s' "$title" "$minutes" >$payload
            shortcuts run "Due Snooze" --input-path $payload
            set -l ret $status
            rm -f $tmp $payload
            if test $ret -eq 0
                printf 'snoozed: %s (+%sm)\n' "$title" "$minutes"
            end
            return $ret

        case '' help -h --help
            echo "usage: due list [--overdue]"
            echo "       due snooze <duration> <title>"

        case '*'
            echo "due: unknown command: $argv[1]" >&2
            echo "usage: due list [--overdue]" >&2
            echo "       due snooze <duration> <title>" >&2
            return 2
    end
end
