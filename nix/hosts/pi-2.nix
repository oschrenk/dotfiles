{
  networking.hostName = "pi-2";

  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/2imqxgbvx6htswijyuswh72kye/pi-2";
    owner = "root";
    mode = "0600";
  };

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
