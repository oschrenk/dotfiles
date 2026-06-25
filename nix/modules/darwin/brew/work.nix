{ ... }:

# Homebrew packages for work machines.
# Import this module in the host file for any work machine.
{
  homebrew.brews = [
    "logcli" # o11y, query loki
    "sleek" # sql, formatter
    "sqlfluff" # sql, formatter
    "stern" # k8s, log "aggregator"
    "websocat" # cli, websocket
  ];

  homebrew.casks = [
    "dbeaver-community" # sql client
    "openvpn-connect" # vpn
  ];
}
