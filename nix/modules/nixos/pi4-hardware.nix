{ ... }: {
  # Disable WiFi and audio via kernel module blacklist
  boot.blacklistedKernelModules = [
    "brcmfmac" "brcmutil"  # WiFi
    "snd_bcm2835"          # Audio
  ];

  # Disable Bluetooth via DTB param (nvmd/nixos-raspberrypi approach)
  hardware.raspberry-pi.config.all.base-dt-params.krnbt = {
    enable = true;
    value = "off";
  };
  hardware.bluetooth.enable = false;

  # Disable HDMI + enable PCIe ASPM
  boot.kernelParams = [
    "video=HDMI-A-1:d"  # HDMI off (saves ~25mA, takes effect after reboot)
    "pcie_aspm=force"   # power-gates USB controller when idle
  ];

  # Autosuspend idle USB devices — exclude mass storage (class 08) to avoid
  # stalling the USB boot drive
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{bDeviceClass}!="08", ATTR{power/control}="auto"
  '';

  # CPU frequency governor — scales with load
  powerManagement.cpuFreqGovernor = "schedutil";
}
