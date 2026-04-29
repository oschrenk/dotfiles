{ config, ... }:
{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.${config.my.personal.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ config.my.personal.sshKey ];
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # allow wheel group to use nix as trusted user — required for remote nixos-rebuild
  nix.settings.trusted-users = [ "@wheel" ];

  # Storage on the Pis is tight (USB stick); without this every nixos-rebuild
  # accumulates old generations and unreferenced store paths until disk fills.
  # Weekly GC, keep 14 days of generations as a rollback buffer.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # mDNS — advertise hostname on local network so Macs can reach pi-1.local etc.
  # without needing static /etc/hosts entries or a DNS server
  services.avahi = {
    enable = true;
    nssmdns4 = true; # lets the Pi itself resolve .local names
    publish = {
      enable = true;
      addresses = true; # broadcast this host's IP under its hostname
    };
  };

  # Use systemd-networkd instead of the default shell-script network stack —
  # more reliable, faster boot, better suited for headless servers
  networking.useNetworkd = true;
  networking.useDHCP = true;

  # "Online" is a broken concept — these services stall boot waiting for a
  # network that may never satisfy their definition of "up"
  # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
  systemd.network.wait-online.enable = false;

  # Prevent network dropping mid-deploy when running nixos-rebuild switch over SSH —
  # uses `systemctl restart` instead of stop+start, so the connection stays alive
  systemd.services.systemd-networkd.stopIfChanged = false;
  # resolved must also stay up so services restarted during deploy can still resolve hostnames
  systemd.services.systemd-resolved.stopIfChanged = false;

  # Don't derive IPv6 addresses from the MAC.
  #
  # By default, Linux builds an IPv6 address by taking the network prefix
  # (handed out by your ISP) and gluing the MAC onto it. So if anyone knows
  # both your prefix and your MAC, they can compute the public IPv6 of this
  # machine and try to reach it directly.
  #
  # Setting addr_gen_mode = 2 tells the kernel to use a stable random
  # suffix instead. Same address every time on the same network (so services
  # keep working), but no longer guessable from the MAC alone. This makes it
  # safe to publish MACs (e.g. in this repo) without leaking IPv6 addresses.
  #
  # `all` covers existing interfaces; `default` covers any new ones (e.g.
  # tailscale0, container bridges) that get added later.
  boot.kernel.sysctl."net.ipv6.conf.all.addr_gen_mode" = 2;
  boot.kernel.sysctl."net.ipv6.conf.default.addr_gen_mode" = 2;

  time.timeZone = config.my.personal.timezone;

  system.stateVersion = "25.05";

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
