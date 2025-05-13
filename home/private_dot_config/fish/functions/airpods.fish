function airpods --description "Connect to AirPods"
    blueutil --connect (blueutil --paired --format json | jq -r '.[] | select(.name | test("AirPods")).address' | tail -1 | xargs)
end
