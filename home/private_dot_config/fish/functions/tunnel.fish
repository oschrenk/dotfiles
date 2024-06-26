# For ease of use it is recommended to add your user/group to sudoers
# Like so:
# %Local  ALL=NOPASSWD: /usr/sbin/networksetup -setsocksfirewallproxy *
# %Local  ALL=NOPASSWD: /usr/sbin/networksetup -setsocksfirewallproxystate *
# %Local  ALL=NOPASSWD: /usr/sbin/networksetup -setv6off *
# %Local  ALL=NOPASSWD: /usr/sbin/networksetup -setv6automatic *

function tunnel --description "SSH SOCKS proxy script for macOS"

    # Fetching ip address before establishing tunnel using dns service
    function __public_ip_via_dig -d 'Get public IP through via dig w/o proxy'
        dig -4 @resolver1.opendns.com -t a myip.opendns.com +short
    end

    # Fetching public ip is hard. I didn't find a way to make dig
    # work with Socks5 proxy, so I'm using a public service
    # But..., services like this die like flies and are mostly slow
    #
    # If one is too slow, or does not respond, try another service
    #
    # curl -s "icanhazip.com"
    # curl -s "ifconfig.me/ip"
    function __public_ip_via_socks -a localport -d 'Get public IP through via socks5 proxy'
        curl -s --proxy socks5h://localhost:$localport checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
    end

    function __proxy_on -d 'Enable socks5 proxy'
        set lowerport (sysctl net.inet.ip.portrange.first | cut -d " " -f 2)
        set upperport (sysctl net.inet.ip.portrange.last | cut -d " " -f 2)
        set localport (jot -r 1 $lowerport $upperport)

        set remote_ip_before (__public_ip_via_dig)

        echo "Listening on localhost:$localport"
        echo "Modifying network settings..."

        for device in (__devices)
            echo " - disabling ipv6 for $device"
            sudo /usr/sbin/networksetup -setv6off Wi-Fi
            echo " - enabling proxy for $device"
            sudo /usr/sbin/networksetup -setsocksfirewallproxy "$device" 127.0.0.1 $localport off
        end
        echo "...done"
        echo "Starting SSH session. Will run in background for 1 day."
        ssh -f tunnel -N -D localhost:$localport sleep 1d

        set remote_ip_after (__public_ip_via_socks $localport)
        echo "Your remote ip before connecting through the proxy is $remote_ip_before"
        echo "Your remote ip after  connecting through the proxy is $remote_ip_after"
        echo "The http_proxy for the terminal has NOT been set."
    end

    function __devices
        networksetup -listallnetworkservices | sed 1d | grep -v Bluetooth | grep -v "*"
    end

    function proxy_status -d 'Status of proxy'
        echo "Querying network settings..."

        for device in (__devices)
            echo " - proxy status for $device"
            networksetup -getsocksfirewallproxy "$device"
        end
        echo "... done!"
    end

    function proxy_off
        echo "Modifying network settings..."

        for device in (__devices)
            echo " - enabling ipv6 for $device"
            sudo /usr/sbin/networksetup -setv6automatic Wi-Fi
            echo " - disabling proxy for $device"
            sudo /usr/sbin/networksetup -setsocksfirewallproxystate "$device" off
        end
        echo "... done!"
    end

    function kill_all
        echo "Killing all running proxy connections."
        for pid in (ps -A | grep "ssh -f" | grep "sleep" | awk '{print $1}')
            kill -9 $pid
        end
    end

    function shutdown
        proxy_off
        kill_all
        echo "Proxy shutdown complete!"
    end

    function toggle_state
        if networksetup -getsocksfirewallproxy Wi-Fi | head -1 | cut -d ' ' -f2 | grep -i y >>/dev/null
            shutdown
            echo OFF
        else
            __proxy_on
            echo ON
        end
    end

    function usage
        echo "Usage: tunnel [on|off|killall|shutdown|status]"
        echo "tunnel is fish script to toggle proxy settings in macOS"
        echo "tunnel initiates an SSH tunnel and then enables a Socks proxy"
    end

    switch (echo $argv)
        case on
            __proxy_on
        case off
            proxy_off
        case killall
            kill_all
        case shutdown
            shutdown
        case status
            proxy_status
        case usage
            usage
        case ''
            toggle_state
        case '*'
            echo "Unknown input, try again with different term"
            echo ""
            usage
    end
end
