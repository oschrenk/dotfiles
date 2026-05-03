{
  networking.hostName = "hetzner-1";

  # Tailscale
  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/2imqxgbvx6htswijyuswh72kye/hetzner-1";
    owner = "root";
    mode = "0600";
  };

  # Exit node. Clients opt in with `tailscale up --exit-node=hetzner-1`.
  # IPv4 only: host has no IPv6 configured.
  services.tailscale.useRoutingFeatures = "server";
  services.tailscale.extraUpFlags = [ "--advertise-exit-node" ];
}
