# mark — timestamped homelab events, written to Prometheus on pi-2.
# Package and config both come from the upstream flake's home-manager module.
{ mark, ... }:
{
  imports = [ mark.homeModules.mark ];

  programs.mark = {
    enable = true;

    targets.homelab = {
      default = true;
      # The tailnet MagicDNS name, direct to Prometheus, which has no
      # Traefik route yet.
      url = "http://pi-2:9090/api/v1/write";
    };
  };
}
