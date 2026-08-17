{ ... }:
{
  # Network addresses for every host, shared across all configurations so a
  # host can reference its peers (e.g. pi-1's Traefik proxying to pi-3, or the
  # Macs pinning pi-1 in /etc/hosts). Update here if IPs change.
  my.host = {
    "pi-1" = {
      lanIp = "192.168.1.7";
      tailscaleIp = "100.125.174.68";
      mac = "dc:a6:32:6b:00:e8";
    };

    "pi-2" = {
      lanIp = "192.168.1.228";
      tailscaleIp = "100.116.52.68";
      mac = "dc:a6:32:6a:ff:e7";
    };

    "pi-3" = {
      lanIp = "192.168.1.229";
      tailscaleIp = "100.104.10.48";
      mac = "dc:a6:32:6b:01:20";
    };
  };

  # Every homelab name resolves to pi-1, which reverse-proxies to the backends.
  # Shared so machines without the Traefik config (the Macs) can still pin the
  # names in /etc/hosts.
  my.domain.homelab = {
    name = "home.lan";
    publicName = "lab.oschrenk.gt";
    hostName = "pi-1";
    subdomains = [ "beszel" "gatus" "adguard" "unifi" "fusion" ];
  };
}
