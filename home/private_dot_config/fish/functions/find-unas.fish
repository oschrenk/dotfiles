# Find UNAS 2 on the local network by its MAC address.
# Auto-detects the active interface and subnet.

function find-unas
    set -l UNAS_MAC (op read "op://Personal/UNAS 2/MAC")
    if test -z "$UNAS_MAC"
        echo "Failed to read MAC address from 1Password." >&2
        return 1
    end

    # Get default interface and IP/subnet
    set -l iface (route -n get default 2>/dev/null | awk '/interface:/{print $2}')
    set -l ip (ipconfig getifaddr $iface)
    set -l mask (ifconfig $iface | awk '/inet /{print $4}')

    if test -z "$ip" -o -z "$mask"
        echo "Could not determine network interface or IP." >&2
        return 1
    end

    # Convert hex netmask to CIDR prefix length
    set -l bits 0
    for byte in (string sub -s 3 -- $mask | fold -w2)
        for bit in (echo "obase=2;ibase=16;$(echo $byte | tr a-f A-F)" | bc | grep -o 1)
            set bits (math $bits + 1)
        end
    end
    set -l subnet (string join '.' (string split '.' $ip)[1..3])".0/$bits"

    # Ping sweep to populate ARP table, then look up the MAC
    nmap -sn $subnet >/dev/null 2>&1
    set -l match (arp -a | grep -i $UNAS_MAC | head -1 | awk -F'[()]' '{print $2}')

    if test -n "$match"
        echo $match
    else
        echo "UNAS 2 ($UNAS_MAC) not found on $subnet" >&2
        return 1
    end
end
