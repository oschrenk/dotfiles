{ config, lib, ... }:

# Pin unas.local in /etc/hosts, keeping it a REAL file.
#
# nix-darwin's `environment.etc."hosts"` would manage the file by symlinking it
# into the nix store. macOS's resolver treats a symlinked /etc/hosts specially:
# it deprioritizes it, consulting it only after DNS/mDNS fails to resolve. Since
# the whole reason for pinning unas.local is that mDNS is unreliable, a symlink
# would give exactly the flaky behaviour we're trying to remove (and it makes
# /etc/hosts read-only). See the StackOverflow thread on ".dev" domains
# redirecting to 127.0.53.53 with a symlinked hosts file.
#
# So instead we maintain a marker-delimited block in the real file on every
# activation (postActivation runs as root; a custom-named activation script
# would be silently ignored, hence postActivation + mkAfter). Everything outside
# the markers is left untouched — add your own entries there freely.
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    hosts=/etc/hosts
    begin='# BEGIN managed hosts (nix-darwin) — do not edit between markers'
    end='# END managed hosts (nix-darwin)'
    entry="$(printf '%s\t%s' "${config.my.nas.ip}" "${config.my.nas.hostName}")"
    block="$(printf '%s\n' "$begin" "$entry" "$end")"

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
