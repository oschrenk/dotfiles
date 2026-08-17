{ lib, ... }:

# Trust the homelab's private CA (step-ca on pi-1) in the macOS keychain, so Chrome
# and Safari give home.lan a normal padlock instead of a warning.
#
# Let's Encrypt cannot issue for home.lan — '.lan' is not a public TLD, so there is
# nothing to validate. Traefik therefore gets its certs from step-ca
# (modules/nixos/step-ca.nix), a CA that only this network knows about. Nothing
# trusts it until we say so.
#
# The PEM is committed next to this file. That is deliberate: a root CA certificate
# holds the CA's PUBLIC key and is meant to be handed out. The private key — the
# half that can actually issue certs — never leaves pi-1. Same distinction as
# identity.nix committing the SSH public key.
#
# Keeping it here rather than in 1Password also means the cert is an input to the
# build, not a file staged into the home directory at runtime. It exists only for
# the import.
#
# Two trust stores have to be fed separately, and neither covers the other:
#
#   - /etc/ssl/certs/ca-certificates.crt — curl, git, anything linked against
#     OpenSSL. Handled by security.pki below, baked in at BUILD time.
#   - the macOS System keychain         — Chrome and Safari, which ignore the file
#     above entirely. Handled by the activation script, at RUNTIME.
let
  cert = ./homelab-ca.crt;
in
{
  security.pki.certificateFiles = [ cert ];

  # postActivation runs as root, which is what writing to the System keychain needs.
  # mkAfter so this lands after nix-darwin's own activation steps (same pattern as
  # modules/network.nix).
  system.activationScripts.postActivation.text = lib.mkAfter ''
    cert=${cert}
    if [ ! -r "$cert" ]; then
      echo "warning: homelab CA cert unreadable at $cert - skipping keychain install" >&2
    else
      # Compare fingerprints rather than blindly re-adding: add-trusted-cert is not
      # idempotent and would stack duplicate entries in the keychain on every rebuild.
      want=$(/usr/bin/openssl x509 -in "$cert" -noout -fingerprint -sha256 | cut -d= -f2 | tr -d ':')
      have=$(/usr/bin/security find-certificate -a -Z /Library/Keychains/System.keychain 2>/dev/null | awk '/SHA-256 hash:/ {print $3}')
      case "$have" in
        *"$want"*)
          : # already trusted, nothing to do
          ;;
        *)
          if /usr/bin/security add-trusted-cert -d -r trustRoot \
               -k /Library/Keychains/System.keychain "$cert"; then
            echo "homelab CA added to the System keychain - restart Chrome to pick it up"
          else
            # Warn, do not fail: a keychain hiccup should not block an unrelated rebuild.
            echo "warning: could not add homelab CA to the System keychain" >&2
          fi
          ;;
      esac
    fi
  '';
}
