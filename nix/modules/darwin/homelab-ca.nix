{ lib, ... }:

# Trust home.lan's certs. Let's Encrypt can't issue for a fake TLD, so Traefik gets
# them from step-ca on pi-1 (modules/nixos/step-ca.nix) and nothing trusts that CA
# until we say so.
#
# The PEM is committed here on purpose: it's the CA's public half, meant to be handed
# out. The signing key never leaves pi-1.
#
# Both stores are needed. security.pki covers curl/git via
# /etc/ssl/certs/ca-certificates.crt; Chrome and Safari ignore that file and read the
# keychain, hence the activation script.
let
  cert = ./homelab-ca.crt;
in
{
  security.pki.certificateFiles = [ cert ];

  # postActivation runs as root, which the System keychain needs.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    cert=${cert}
    if [ ! -r "$cert" ]; then
      echo "warning: homelab CA cert unreadable at $cert - skipping keychain install" >&2
    else
      # add-trusted-cert isn't idempotent, so check the fingerprint first or every
      # rebuild stacks another copy in the keychain.
      want=$(/usr/bin/openssl x509 -in "$cert" -noout -fingerprint -sha256 | cut -d= -f2 | tr -d ':')
      have=$(/usr/bin/security find-certificate -a -Z /Library/Keychains/System.keychain 2>/dev/null | awk '/SHA-256 hash:/ {print $3}')
      case "$have" in
        *"$want"*)
          : # already trusted
          ;;
        *)
          if /usr/bin/security add-trusted-cert -d -r trustRoot \
               -k /Library/Keychains/System.keychain "$cert"; then
            echo "homelab CA added to the System keychain - restart Chrome to pick it up"
          else
            # Warn rather than fail; a keychain hiccup shouldn't block the rebuild.
            echo "warning: could not add homelab CA to the System keychain" >&2
          fi
          ;;
      esac
    fi
  '';
}
