{ lib, ... }:
{
  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0"; # default 127.0.0.1 blocks Tailscale access
    port = 8090;
    # Initial admin credentials — only applied on first run when no user exists.
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

  # Ensure the data dir exists with correct ownership before opnix-secrets.service
  # runs. opnix writes id_ed25519 here directly (configured via path in the host file).
  systemd.tmpfiles.rules = [
    "d /var/lib/beszel-hub 0700 beszel-hub beszel-hub -"
    "d /var/lib/beszel-hub/beszel_data 0700 beszel-hub beszel-hub -"
  ];

  systemd.services.beszel-hub = {
    # Wait for opnix to place the SSH key before starting.
    after = [ "opnix-secrets.service" ];
    wants = [ "opnix-secrets.service" ];
    serviceConfig = {
      # Override DynamicUser so the static beszel-hub user above is used instead.
      # Required because opnix can only chown files to users that already exist at
      # activation time — dynamic users are created on-demand by systemd at service
      # start, which is too late.
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "beszel-hub";
      Group = lib.mkForce "beszel-hub";
    };
  };
}
