function tunnel --description "SSH SOCKS proxy script for Mac OS X"

  # Fetching ip address before the thunnel is easy, just use dns service for that
  function _remote_ip_before
    dig -4 @resolver1.opendns.com -t a myip.opendns.com +short
  end

  # service like this, die like flies and are mostly slow
  # enable one of these
  function _remote_ip_after
    # curl -s -S --socks5 127.0.0.1:$localport "ifconfig.me/ip"
    curl -s -S --socks5 127.0.0.1:$localport "ifconfig.me/ip"
  end

  function proxy_on
    set lowerport (sysctl net.inet.ip.portrange.first | cut -d " " -f 2)
    set upperport (sysctl net.inet.ip.portrange.last | cut -d " " -f 2)
    set localport (jot -r 1 $lowerport $upperport)

    set remote_ip_before (_remote_ip_before)

    echo "Listening on localhost:$localport."
    echo "Modifying network settings..."

    # Ask for the administrator password upfront
    sudo -v

    for device in (networksetup -listallnetworkservices | sed '1d' | grep -v "Bluetooth")
      echo " - enabling proxy for $device"
      sudo networksetup -setsocksfirewallproxy "$device" 127.0.0.1 $localport off
    end
    echo "...done"
    echo "Starting SSH session. Will run in background for 1 day."
    ssh -f tunnel -N -D localhost:$localport sleep 1d

    set remote_ip_after (curl -s -S --socks5 127.0.0.1:$localport "ifconfig.me/ip")
    echo "Your remote ip before connecting through the proxy is $remote_ip_before"
    echo "Your remote ip after  connecting through the proxy is $remote_ip_after"
    echo "The http_proxy for the terminal has NOT been set."
  end

  function proxy_off
    echo "Modifying network settings..."

    # Ask for the administrator password upfront
    sudo -v

    for device in (networksetup -listallnetworkservices | sed '1d' | grep -v "Bluetooth")
      echo " - disabling proxy for $device"
      sudo networksetup -setsocksfirewallproxystate "$device" off
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
    if networksetup -getsocksfirewallproxy Wi-Fi | head -1 | cut -d ' ' -f2 | grep -i 'y' >> /dev/null
      shutdown
      echo "OFF"
    else
      proxy_on
      echo "ON"
    end
  end

  function usage
    echo "Usage: tunnel [on|off|killall|shutdown|no_args]"
    echo "tunnel is fish script to toggle proxy settings in OSX"
    echo "tunnel initiates an SSH tunnel and then enables a Socks proxy"
  end

  switch (echo $argv)
    case on
      proxy_on
    case off
      proxy_off
    case killall
      kill_all
    case shutdown
      shutdown
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
