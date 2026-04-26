# Bootstrap (once, before first deploy) — see plans/ca.md for full instructions.
#   sudo mkdir -p /var/lib/step-ca/.step
#   sudo env STEPPATH=/var/lib/step-ca/.step nix-shell -p step-cli --run \
#     "step ca init --name 'pi-1 homelab CA' --dns 'pi-1.local' --dns 'localhost' \
#      --address '127.0.0.1:8443' --provisioner admin --deployment-type standalone"
#   sudo env STEPPATH=/var/lib/step-ca/.step nix-shell -p step-cli --run \
#     "step ca provisioner add acme --type ACME"
# Store ca.json and root_ca.crt in 1Password; update opnix refs in pi-1.nix.

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
      # settings required by module but ignored — ExecStart overrides with opnix-provided ca.json.
      settings = {};
      intermediatePasswordFile = "/run/step-ca-password";
    };

    systemd.services.step-ca = {
      after    = [ "opnix-secrets.service" ];
      requires = [ "opnix-secrets.service" ];
      serviceConfig = {
        # DynamicUser=true creates a private symlink namespace; its dynamic UID conflicts
        # with systemd-tmpfiles Z rules, causing permission errors on nixos-rebuild switch.
        DynamicUser = lib.mkForce false;
        ExecStart = lib.mkForce [
          ""
          "${config.services.step-ca.package}/bin/step-ca /run/step-ca.json --password-file \${CREDENTIALS_DIRECTORY}/intermediate_password"
        ];
      };
    };

    users.users.step-ca = {
      isSystemUser = true;
      group        = "step-ca";
      home         = "/var/lib/step-ca";
    };
    users.groups.step-ca = {};

    # Fix ownership of .step/ created by bootstrap (runs as root) on every boot.
    systemd.tmpfiles.rules = [
      "Z /var/lib/step-ca/.step 0700 step-ca step-ca -"
    ];
  };
}
