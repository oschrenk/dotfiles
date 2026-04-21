function find-pi --description 'Find Raspberry Pi devices on the local network'
    if set -q argv[1]
        set iface $argv[1]
    else
        set iface (route -n get default 2>/dev/null | awk '/interface:/{print $2}')
    end

    set -l ip (ipconfig getifaddr $iface)
    set -l mask (ifconfig $iface | awk '/inet /{print $4}')

    if string match -q '*tun*' $iface
        echo "Active interface is '$iface' (VPN?). Disconnect VPN and try again." >&2
        return 1
    end

    if test -z "$ip" -o -z "$mask"
        echo "Could not determine network interface or IP." >&2
        return 1
    end

    set -l bits 0
    for byte in (string sub -s 3 -- $mask | fold -w2)
        for bit in (echo "obase=2;ibase=16;"(echo $byte | tr a-f A-F) | bc | grep -o 1)
            set bits (math $bits + 1)
        end
    end
    set -l subnet (string join '.' (string split '.' $ip)[1..3])".0/$bits"

    echo "Scanning net: $subnet"
    sudo nmap -sn "$subnet" | grep -B 2 'Raspberry' | grep 'report for' | sed 's/Nmap scan report for //'
end
