{
  config,
  lib,
  pkgs,
  ...
}:

let
  builderName = "nix-builder-aarch64";
  builderMaxJobs = 4;
  builderSpeedFactor = 1;

  # Same derivation the module uses in module/common.nix.
  containerUser = config.services.containerization.user;
  builderHome =
    if config.users.users ? ${containerUser} then
      config.users.users.${containerUser}.home
    else
      "/Users/${containerUser}";
in
{
  services.containerization = {
    enable = true;
    linux-builder.aarch64.enable = true;
    # Started on demand: the autoStart agent runs stop + rm before run, and the
    # runtime keeps /nix/store in the container's writable layer.
    containers.${builderName}.autoStart = lib.mkForce false;
  };

  # nix.buildMachines is inert under Determinate Nix, so the builder list goes
  # in the drop-in. The host is the ssh alias the module writes to
  # /etc/ssh/ssh_config.d, which the root daemon reads.
  environment.etc."nix/nix.custom.conf".text = ''
    builders = ssh-ng://root@${builderName} aarch64-linux ${builderHome}/.ssh/nix-builder_ed25519 ${toString builderMaxJobs} ${toString builderSpeedFactor} big-parallel -
  '';

  environment.systemPackages = [ pkgs.socktainer ];
}
