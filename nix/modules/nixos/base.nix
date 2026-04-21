{ ... }:
{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users.oliver = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ0G3UHhaDSkbGrbopLIIrp5CRh48opdepjUQQPTJ+r"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # allow wheel group to use nix as trusted user — required for remote nixos-rebuild
  nix.settings.trusted-users = [ "@wheel" ];

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

  time.timeZone = "America/Guatemala";

  system.stateVersion = "25.05";

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
