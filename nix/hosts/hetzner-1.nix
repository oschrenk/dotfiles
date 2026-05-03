{
  networking.hostName = "hetzner-1";

  # Tailscale
  services.onepassword-secrets.secrets.tailscaleAuthKey = {
    reference = "op://2udkjdngrnb6jlr62cd7iq33de/2imqxgbvx6htswijyuswh72kye/hetzner-1";
    owner = "root";
    mode = "0600";
  };
}
