{ config, lib, ... }:

# Pin LAN hostnames in /etc/hosts, keeping it a REAL file.
#
# nix-darwin's `environment.etc."hosts"` would manage the file by symlinking it
# into the nix store. macOS's resolver treats a symlinked /etc/hosts specially:
# it deprioritizes it, consulting it only after DNS/mDNS fails to resolve. Since
# the whole reason for pinning these names is that the LAN's own name resolution
# is unreliable, a symlink would give exactly the flaky behaviour we're trying to
# remove (and it makes /etc/hosts read-only). See the StackOverflow thread on
# ".dev" domains redirecting to 127.0.53.53 with a symlinked hosts file.
#
# So instead we maintain a marker-delimited block in the real file on every
# activation (postActivation runs as root; a custom-named activation script
# would be silently ignored, hence postActivation + mkAfter). Everything outside
# the markers is left untouched — add your own entries there freely.
let
  domain = config.my.domain.homelab.name;
  homelabHost = config.my.domain.homelab.hostName;

  entries = [
    {
      ip = config.my.nas.ip;
      names = [ config.my.nas.hostName ];
    }
    # Everything under home.lan is served by pi-1's reverse proxy. Pinning them
    # here means the homelab resolves without AdGuard being the active resolver.
    {
      ip = config.my.host.${homelabHost}.lanIp;
      names = [ homelabHost domain ] ++ map (s: "${s}.${domain}") config.my.domain.homelab.subdomains;
    }
  ];

  begin = "# BEGIN managed hosts (nix-darwin) — do not edit between markers";
  end = "# END managed hosts (nix-darwin)";
  lines = map (e: "${e.ip}\t${lib.concatStringsSep " " e.names}") entries;
in
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    hosts=/etc/hosts
    begin=${lib.escapeShellArg begin}
    end=${lib.escapeShellArg end}
    block="$(printf '%s\n' ${lib.escapeShellArgs ([ begin ] ++ lines ++ [ end ])})"

    current="$(awk -v b="$begin" -v e="$end" '$0==b{f=1} f{print} $0==e{f=0}' "$hosts")"
    if [ "$current" != "$block" ]; then
      tmp="$(mktemp)"
      # keep everything outside the managed block, then append the fresh block
      awk -v b="$begin" -v e="$end" '$0==b{f=1} !f{print} $0==e{f=0}' "$hosts" > "$tmp"
      printf '%s\n' "$block" >> "$tmp"
      # truncate-in-place so the file stays a regular root:wheel 0644 file
      # (preserves inode/owner/perms — never becomes a symlink)
      cat "$tmp" > "$hosts"
      rm -f "$tmp"
    fi
  '';
}
