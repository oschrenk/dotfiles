{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hetzner Cloud ARM quirks: without these the console blanks and boot stalls
  # on the Ampere Altra firmware. Documented in
  # https://discourse.nixos.org/t/nixos-on-hetzner-cloud-arm/29186
  boot.kernelParams = [ "console=tty" ];
  boot.initrd.kernelModules = [ "virtio_gpu" ];

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
  ];
}
