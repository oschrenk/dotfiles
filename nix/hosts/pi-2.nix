{
  # Host network addresses. Update here if IPs change.
  my.host."pi-2" = {
    lanIp = "192.168.1.228";
    tailscaleIp = "100.116.52.68";
    mac = "dc:a6:32:6a:ff:e7";
  };

  # Networking
  networking.hostName = "pi-2";

  # Pin hostnames to static IPs to bypass unreliable Avahi DNS on UNAS.
  # Update and redeploy if IPs change.
  networking.hosts = {
    "192.168.1.241" = [ "unas.local" ];
  };

  # Tailscale
  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/2imqxgbvx6htswijyuswh72kye/pi-2";
    owner = "root";
    mode = "0600";
  };

  # Beszel
  services.onepassword-secrets.secrets.beszelAgentKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/pr3tmmcv6crtd36wqyqh3vdnmu/Public Key";
    owner = "beszel-agent";
    mode = "0600";
  };

  # Storage
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [
      "noatime" # don't update file access times on reads — reduces writes on flash storage
    ];
  };

  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    options = [
      "noatime" # don't update access times — reduces writes on flash storage
      "noauto" # don't mount at boot — only needed when updating bootloader/firmware
      "x-systemd.automount" # mount on demand when something accesses /boot/firmware
      "x-systemd.idle-timeout=1min" # unmount after 1 min idle — keeps FAT32 partition safe from corruption
    ];
  };
}
