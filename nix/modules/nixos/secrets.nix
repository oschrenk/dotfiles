{ pkgs, opnix, ... }:
{
  environment.systemPackages = [ opnix.packages.${pkgs.system}.default ];

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
  };

  services.tailscale.authKeyFile = "/var/lib/opnix/secrets/tailscaleAuthKey";
}
