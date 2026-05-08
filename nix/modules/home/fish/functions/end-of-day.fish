#!/usr/bin/env fish

echo "🌅 End of Day"
echo ""

# Quit an application
function quit_app
    set app_name $argv[1]
    if pgrep -x "$app_name" >/dev/null
        echo "Closing $app_name..."
        osascript -e "quit app \"$app_name\"" 2>/dev/null
        sleep 1
    else
        echo "$app_name is not running"
    end
end

# Close applications gently
quit_app Slack
quit_app "IntelliJ IDEA"
quit_app "Docker Desktop"
quit_app "OpenVPN Connect"

echo ""
echo "🔍 Checking for running development processes..."
echo ""

# Check for node processes
set node_pids (pgrep -x node)
if test -n "$node_pids"
    echo "Found running Node processes:"
    echo ""
    for pid in $node_pids
        set cmd (ps -p $pid -o command | tail -n +2)
        echo "  PID $pid: $cmd"
        read -P "  Kill this process? (y/N): " response
        if string match -qir '^y' -- $response
            kill -TERM $pid
            echo "  → Killed"
        else
            echo "  → Skipped"
        end
        echo ""
    end
else
    echo "No node processes running"
end

echo ""

# Check for JVM processes (excluding IntelliJ IDEA)
set jvm_pids (ps aux | grep java | grep -v grep | grep -v "IntelliJ IDEA" | grep -v "JetBrains" | awk '{print $2}')
if test -n "$jvm_pids"
    echo "Found running JVM processes:"
    set pids_csv (string join ',' $jvm_pids)
    ps -p $pids_csv -o pid,command | tail -n +2
    echo ""
    read -P "Kill all JVM processes? (y/N): " response
    if string match -qir '^y' -- $response
        echo "Stopping JVM processes..."
        for pid in $jvm_pids
            kill -TERM $pid
        end
        sleep 2
        echo "JVM processes stopped"
    else
        echo "Skipping JVM processes"
    end
else
    echo "No JVM processes running"
end

echo ""
echo "✅ All done. Have a great evening!"
