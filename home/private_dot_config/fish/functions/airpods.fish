# Requirements
# brew install jq blueutil
function pods --description "Connect to AirPods"
    set -l airpods_mac_address_paired (blueutil --paired --format json | jq -r '.[] | select(.name | test("AirPods")).address' | tail -1 | xargs)
    set -l airpods_mac_address_connected (blueutil --connected --format json | jq -r '.[] | select(.name | test("AirPods")).address' | tail -1 | xargs)

    if test -z "$airpods_mac_address_paired"
        echo "No AirPods found."
        return 1
    end

    if test "$airpods_mac_address_paired" = "$airpods_mac_address_connected"
        echo "AirPods already connected at $airpods_mac_address_paired."
        return 0
    end

    echo "Connecting to AirPods at $airpods_mac_address_paired..."
    blueutil --connect "$airpods_mac_address_paired"

    if test $status -eq 0
        echo "Connected."
    else
        echo "Error: Failed to connect."
        return 1
    end
end
