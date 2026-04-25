{ ... }:
{
  services.beszel.agent = {
    enable = true;
    # Public key injected via opnix — stored in 1Password as "KEY=ssh-ed25519 AAAA..."
    environmentFile = "/var/lib/opnix/secrets/beszelAgentKey";
  };
  # Agent listens on port 45876. tailscale0 is already trusted so the hub
  # can reach agents without openFirewall = true.
}
