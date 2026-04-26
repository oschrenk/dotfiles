# Bootstrap required before first deploy — run once on the Pi:
#
#   sudo mkdir -p /var/lib/step-ca/.step
#   sudo env STEPPATH=/var/lib/step-ca/.step nix-shell -p step-cli --run "step ca init \
#     --name 'pi-1 homelab CA' --dns 'pi-1.local' --address '127.0.0.1:8443' \
#     --provisioner admin --deployment-type standalone"
#   sudo env STEPPATH=/var/lib/step-ca/.step nix-shell -p step-cli --run \
#     "step ca provisioner add acme --type ACME"
#
# Then store ca.json in 1Password:
#   ssh pi-1 'sudo cat /var/lib/step-ca/.step/config/ca.json' > /tmp/ca.json
#   # paste contents into 1Password and update the opnix references in pi-1.nix
#
# Verify after first deploy:
#   ssh pi-1 'journalctl -u step-ca -n 50'
#   ssh pi-1 'curl -s https://127.0.0.1:8443/acme/acme/directory'

{ config, lib, ... }:
let
  cfg = config.services.homelab-ca;
in
{
  options.services.homelab-ca = {
    port = lib.mkOption {
      type        = lib.types.port;
      default     = 8443;
      description = "Port step-ca listens on. Read by traefik.nix for the ACME URL.";
    };
  };

  config = {
    services.step-ca = {
      enable  = true;
      address = "127.0.0.1";
      port    = cfg.port;
      # settings is required by the nixpkgs module but ignored at runtime —
      # ExecStart below points step-ca at the opnix-provided /run/step-ca.json.
      settings = {};
      # opnix writes the intermediate key password to /run/ (tmpfs) on every boot.
      intermediatePasswordFile = "/run/step-ca-password";
    };

    systemd.services.step-ca = {
      after    = [ "opnix-secrets.service" ];
      requires = [ "opnix-secrets.service" ];
      serviceConfig.ExecStart = lib.mkForce [
        ""
        "${config.services.step-ca.package}/bin/step-ca /run/step-ca.json --password-file \${CREDENTIALS_DIRECTORY}/intermediate_password"
      ];
    };

    # Bootstrap creates .step/ as root; this ensures step-ca user can read it on every boot.
    systemd.tmpfiles.rules = [
      "Z /var/lib/step-ca/.step 0700 step-ca step-ca -"
    ];
  };
}
