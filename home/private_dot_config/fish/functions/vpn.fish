function vpn --description "Show active VPN connections as JSON"
    set -l active

    set -l nc (scutil --nc list 2>/dev/null | string collect)
    string match -qr '\(Connected\).*io\.tailscale' -- $nc; and set -a active tailscale
    string match -qr '\(Connected\).*com\.nordvpn'  -- $nc; and set -a active nordvpn

    if ifconfig 2>/dev/null | awk '/inet .* --> / && $2 != $4 { f=1 } END { exit !f }'
        set -a active openvpn
    end

    if test (count $active) -eq 0
        echo '{"active": []}'
    else
        printf '%s\n' $active | jq -R . | jq -sc '{active: .}'
    end
end
