# Self-contained Slack client built on the web API with curl. Replaces the
# slack-cli binary that used to own this name; nothing here shells out to it.

function __slack_usage
    echo 'Usage: slack send [-c CHANNEL] [-k KIND] [-a WHEN] [-n] MESSAGE'
    echo '       slack review [MR] [-c CHANNEL] [-a WHEN] [-n]'
    echo '       slack list'
    echo '       slack cancel ID'
    echo ''
    echo 'Common flags'
    echo '  -c, --channel  Slack channel (default: #backend)'
    echo '  -a, --at       when to post, e.g. "09:00", "tomorrow 09:00",'
    echo '                 "2026-08-20 14:30" (default: post now)'
    echo '  -n, --dry-run  print what would be sent, call nothing'
    echo ''
    echo 'send   — post arbitrary content'
    echo '  -k, --kind     text (default) | block | attachment'
    echo '                 block and attachment take JSON as the MESSAGE'
    echo ''
    echo 'review — post "Please review" plus an MR title and URL'
    echo '  MR             MR iid or branch (default: current branch)'
    echo ''
    echo 'list   — messages still queued at Slack (invisible in the Slack app)'
    echo 'cancel — delete a queued message by the id that list shows'
    echo ''
    echo 'Examples:'
    echo '  slack send "deploy is done"'
    echo '  slack send -c "#dev" -a "tomorrow 08:00" "standup in 15"'
    echo '  slack send (printf \'one\\n\\nthree\' | string collect)'
    echo '  slack review --dry-run'
    echo '  slack review --at "tomorrow 09:00"'
    echo '  slack list'
    echo '  slack cancel Q0BQ07ECBN2'
end

function __slack_api --description 'POST to a Slack API method, echo the raw response'
    curl -sS -X POST "https://slack.com/api/$argv[1]" \
        -H "Authorization: Bearer $SLACK_TOKEN" \
        -H 'Content-Type: application/json; charset=utf-8' \
        -d "$argv[2]"
end

function __slack_token_check
    if not set -q SLACK_TOKEN
        echo 'slack: SLACK_TOKEN is not set' >&2
        return 1
    end
end

function __slack_ok --description 'Return 0 if a Slack response is ok, else print its error'
    if test (echo $argv[1] | jq -r '.ok') = true
        return 0
    end
    echo "slack: rejected by Slack: "(echo $argv[1] | jq -r '.error') >&2
    return 1
end

function __slack_queued --description 'Echo the raw chat.scheduledMessages.list response'
    __slack_api chat.scheduledMessages.list '{"limit":100}'
end

# Shared tail for send and review: takes a channel and a JSON object holding the
# content (text / blocks / attachments), then posts or schedules it.
#   $argv[1] channel   $argv[2] content JSON   $argv[3] --at string or ''   $argv[4] 1 if dry run
function __slack_dispatch
    set -l channel $argv[1]
    set -l content $argv[2]
    set -l at $argv[3]
    set -l dry $argv[4]

    set -l endpoint chat.postMessage
    set -l payload (jq -nc --arg c $channel --argjson body $content '{channel:$c} + $body')

    if test -n "$at"
        set -l epoch (date -d "$at" +%s 2>/dev/null)
        if test -z "$epoch"
            echo "slack: cannot parse time \"$at\"" >&2
            return 1
        end
        if test $epoch -le (date +%s)
            # Suggesting "tomorrow" only makes sense for a bare clock time.
            if string match -qr '^\s*\d{1,2}:\d{2}\s*$' -- "$at"
                echo "slack: \"$at\" already passed today — try \"tomorrow $at\"" >&2
            else
                echo "slack: \"$at\" is in the past" >&2
            end
            return 1
        end
        set endpoint chat.scheduleMessage
        set payload (echo $payload | jq -c --argjson at $epoch '. + {post_at:$at}')
        echo "→ $channel at "(date -d "@$epoch" '+%a %d %b %H:%M')
    else
        echo "→ $channel now"
    end

    if test "$dry" = 1
        echo "dry run: POST https://slack.com/api/$endpoint"
        echo $payload | jq .
        return 0
    end

    set -l response (__slack_api $endpoint $payload)
    __slack_ok $response; or return 1

    set -l id (echo $response | jq -r '.scheduled_message_id // empty')
    if test -n "$id"
        echo "scheduled ($id) — cancel with: slack cancel $id"
    else
        echo sent
    end
end

function __slack_send
    argparse 'c/channel=' 'k/kind=' 'a/at=' 'n/dry-run' -- $argv
    or return 1

    __slack_token_check; or return 1

    set -l channel '#backend'
    set -q _flag_channel; and set channel $_flag_channel

    set -l kind text
    set -q _flag_kind; and set kind $_flag_kind

    set -l message "$argv[1]"
    if test -z "$message"
        echo 'slack: send needs a message' >&2
        return 1
    end

    set -l content
    switch $kind
        case text
            set content (jq -nc --arg t $message '{text:$t}')
        case block attachment
            if not echo $message | jq -e . >/dev/null 2>&1
                echo "slack: --kind $kind needs valid JSON as the message" >&2
                return 1
            end
            # Slack wants an array for both; wrap a bare object.
            set -l arr (echo $message | jq -c 'if type == "array" then . else [.] end')
            if test $kind = block
                set content (jq -nc --argjson v $arr '{blocks:$v}')
            else
                set content (jq -nc --argjson v $arr '{attachments:$v}')
            end
        case '*'
            echo "slack: unknown kind '$kind' (text, block, attachment)" >&2
            return 1
    end

    set -l at ''
    set -q _flag_at; and set at $_flag_at
    set -l dry 0
    set -q _flag_dry_run; and set dry 1

    __slack_dispatch $channel $content "$at" $dry
end

function __slack_review
    argparse 'c/channel=' 'a/at=' 'n/dry-run' -- $argv
    or return 1

    __slack_token_check; or return 1

    set -l channel '#backend'
    set -q _flag_channel; and set channel $_flag_channel

    # No argument means glab falls back to the current branch's MR.
    set -l mr (glab mr view $argv[1] -F json 2>/dev/null | jq -r '.title, .web_url')
    if test (count $mr) -lt 2; or test -z "$mr[2]"
        echo 'slack: no MR found (wrong branch, or pass an iid)' >&2
        return 1
    end

    # string collect keeps the newlines in one argument; fish would otherwise
    # split the substitution into four separate arguments.
    set -l text (printf 'Please review\n\n%s\n%s' $mr[1] $mr[2] | string collect)
    set -l content (jq -nc --arg t $text '{text:$t}')

    set -l at ''
    set -q _flag_at; and set at $_flag_at
    set -l dry 0
    set -q _flag_dry_run; and set dry 1

    __slack_dispatch $channel $content "$at" $dry
end

function __slack_list
    __slack_token_check; or return 1

    set -l queued (__slack_queued)
    __slack_ok $queued; or return 1

    # Channel names need a scope this token lacks, so channel ids it is.
    set -l rows (echo $queued | jq -r '
        .scheduled_messages | sort_by(.post_at) | .[] |
        [ .id, .channel_id,
          (.post_at | strflocaltime("%a %d %b %H:%M")),
          (.text | gsub("\n+"; " · ") | .[0:56])
        ] | @tsv')

    if test (count $rows) -eq 0
        echo 'nothing queued'
        return 0
    end
    printf '%s\n' $rows | column -t -s \t
end

function __slack_cancel
    __slack_token_check; or return 1

    set -l id $argv[1]
    if test -z "$id"
        echo 'slack: cancel needs an id (see: slack list)' >&2
        return 1
    end

    set -l queued (__slack_queued)
    __slack_ok $queued; or return 1

    # Deleting needs the channel too, and only the queue knows which one.
    set -l channel_id (echo $queued | jq -r --arg id "$id" \
        '.scheduled_messages[] | select(.id == $id) | .channel_id')
    if test -z "$channel_id"
        echo "slack: nothing queued with id $id" >&2
        return 1
    end

    set -l payload (jq -nc --arg c $channel_id --arg id "$id" \
        '{channel:$c, scheduled_message_id:$id}')
    set -l response (__slack_api chat.deleteScheduledMessage $payload)
    __slack_ok $response; or return 1
    echo "cancelled $id"
end

function slack --description 'Slack from the terminal: send, schedule, MR review pings'
    if not set -q argv[1]
        __slack_usage
        return 0
    end

    set -l cmd $argv[1]
    set -l rest
    if set -q argv[2]
        set rest $argv[2..-1]
    end

    switch $cmd
        case send
            __slack_send $rest
            return $status
        case review
            __slack_review $rest
            return $status
        case list
            __slack_list
            return $status
        case cancel
            __slack_cancel $rest
            return $status
        case help --help -h
            __slack_usage
        case '*'
            echo "slack: unknown command '$cmd' (try: slack help)" >&2
            return 1
    end
end
