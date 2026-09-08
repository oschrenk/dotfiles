{
  lib,
  pkgs,
  opnix,
  ...
}:
{
  environment.systemPackages = [ opnix.packages.${pkgs.system}.default ];

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
  };

  services.tailscale.authKeyFile = "/var/lib/opnix/secrets/tailscaleAuthKey";

  # A boot while the ISP is down leaves my.1password.eu unresolvable, and opnix
  # exits non-zero. The upstream unit already sets Restart=on-failure, but
  # StartLimitBurst=2 within an hour stops it after two tries, and systemd then
  # refuses to start it again at all. Every dependent carries
  # Requires=opnix-secrets.service, so the whole homelab stays down until someone
  # runs reset-failed by hand — which is what happened on 2026-09-07.
  #
  # Retry forever instead. Ordering is already correct (After/Wants
  # network-online.target and nss-lookup.target); the unit did not start too
  # early, it gave up too soon.
  # mkForce because the upstream opnix module sets StartLimitIntervalSec itself.
  # Exponential backoff needs systemd 254; the pis run 260.
  systemd.services.opnix-secrets = {
    unitConfig.StartLimitIntervalSec = lib.mkForce 0;
    serviceConfig = {
      # 10s, 19, 36, 68, 128, 3m, 5m, then 10min forever.
      RestartSec = lib.mkForce 10;
      RestartSteps = 8;
      RestartMaxDelaySec = "10min";
    };
  };
}
