{ ... }:
{
  # Disable WiFi and audio via kernel module blacklist
  boot.blacklistedKernelModules = [
    "brcmfmac"
    "brcmutil" # WiFi
    "snd_bcm2835" # Audio
  ];

  # Disable Bluetooth via DTB param (nvmd/nixos-raspberrypi approach)
  hardware.raspberry-pi.config.all.base-dt-params.krnbt = {
    enable = true;
    value = "off";
  };
  hardware.bluetooth.enable = false;

  # PoE HAT (2018, rpi-poe overlay) fan curve — temps in m°C, speeds PWM 0–255
  # Defaults: 40/45/50/55°C at 0/1/10/100 — fan kicks in too early
  # Ours: off until 50°C, full speed at 75°C
  hardware.raspberry-pi.config.pi4.dt-overlays.rpi-poe.enable = true;
  hardware.raspberry-pi.config.pi4.dt-overlays.rpi-poe.params = {
    poe_fan_temp0 = {
      enable = true;
      value = "50000";
    }; # 50°C — fan starts
    poe_fan_speed0 = {
      enable = true;
      value = "0";
    };
    poe_fan_temp1 = {
      enable = true;
      value = "60000";
    }; # 60°C — ~33%
    poe_fan_speed1 = {
      enable = true;
      value = "85";
    };
    poe_fan_temp2 = {
      enable = true;
      value = "70000";
    }; # 70°C — ~67%
    poe_fan_speed2 = {
      enable = true;
      value = "170";
    };
    poe_fan_temp3 = {
      enable = true;
      value = "75000";
    }; # 75°C — full
    poe_fan_speed3 = {
      enable = true;
      value = "255";
    };
  };

  # Disable HDMI + enable PCIe ASPM
  boot.kernelParams = [
    "video=HDMI-A-1:d" # HDMI off (saves ~25mA, takes effect after reboot)
    "pcie_aspm=force" # power-gates USB controller when idle
  ];

  # Autosuspend idle USB devices — exclude mass storage (class 08) to avoid
  # stalling the USB boot drive
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{bDeviceClass}!="08", ATTR{power/control}="auto"
  '';

  # CPU frequency governor — schedutil integrates with the kernel scheduler,
  # scales frequency proportionally to load (better than ondemand's threshold approach)
  powerManagement.cpuFreqGovernor = "schedutil";

  # Disable ARM boost — nvmd enables arm_boost=1 by default, which turbos the Pi4
  # from 1.5GHz to 1.8GHz. Not worth the extra power for a headless home server.
  hardware.raspberry-pi.config.pi4.base-dt-params.arm_boost = {
    enable = true;
    value = "0";
  };
}
