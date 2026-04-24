{ lib, pkgs, ... }:
let
  systemsConfig = pkgs.writeText "beszel-systems.yml" ''
    systems:
      - name: "pi-1"
        host: "100.125.174.68"
        port: 45876
      - name: "pi-2"
        host: "100.116.52.68"
        port: 45876
      - name: "pi-3"
        host: "100.104.10.48"
        port: 45876
  '';
in
{
  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0"; # default 127.0.0.1 blocks Tailscale access
    port = 8090;
    # Initial admin credentials -- only applied on first run when no user exists.
    # Stored as a two-line systemd env file in 1Password notesPlain field.
    environmentFile = "/var/lib/opnix/secrets/beszelHubAdmin";
  };

  # The upstream beszel module uses DynamicUser=true, which implies PrivateUsers=true
  # (user namespace isolation). That makes it impossible to pre-place the SSH key:
  # opnix runs before the service starts, so the dynamic user doesn't exist yet and
  # opnix can't chown the file to it. We override to a static system user so the
  # user exists at activation time when opnix writes the key.
  users.users.beszel-hub = {
    isSystemUser = true;
    group = "beszel-hub";
  };
  users.groups.beszel-hub = { };

  # Pre-create both directories so opnix can write id_ed25519 into beszel_data/
  # before the service starts. The key lives at beszel_data/id_ed25519, not at
  # the top-level data dir.
  systemd.tmpfiles.rules = [
    "d /var/lib/beszel-hub 0700 beszel-hub beszel-hub -"
    "d /var/lib/beszel-hub/beszel_data 0700 beszel-hub beszel-hub -"
  ];

  systemd.services.beszel-hub = {
    # Wait for opnix to place the SSH key before starting.
    after = [ "opnix-secrets.service" ];
    wants = [ "opnix-secrets.service" ];
    serviceConfig = {
      # Copy systems config from the Nix store before each start. The store path
      # changes when the config changes, so the unit changes too -- triggering an
      # automatic restart on deploy. The service has ReadWritePaths=dataDir so
      # beszel-hub user can write here without root or activation scripts.
      ExecStartPre = lib.mkBefore [ "${pkgs.coreutils}/bin/cp ${systemsConfig} /var/lib/beszel-hub/beszel_data/config.yml" ];
      # Override DynamicUser so the static beszel-hub user above is used instead.
      # Required because opnix can only chown files to users that already exist at
      # activation time -- dynamic users are created on-demand by systemd at service
      # start, which is too late.
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "beszel-hub";
      Group = lib.mkForce "beszel-hub";
    };
  };
}
