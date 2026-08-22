# opnix

Secrets pulled from 1Password at activation by
[opnix](https://github.com/brizzbuzz/opnix), declared in `modules/darwin/secrets.nix`
and `modules/nixos/secrets.nix`.

- Secrets are written to `/var/lib/opnix/secrets/<name>`
- One field per file, holding the literal field value
- Nothing secret is in git: the config holds `op://` references, which are pointers

## The Token

opnix authenticates with a 1Password **service-account token** at `/etc/opnix-token`.

- **Per machine, and never managed by Nix.** A rebuild will not create it
- **One service account per context, scoped read-only to one vault.** Homelab uses
  *Service Account / opnix-bootstrap*; a work machine gets its own, so a compromise
  there cannot read personal secrets
- Rotate it on a schedule and give it an expiry

**A missing token fails silently.** opnix logs a warning and exits 0, so the rebuild
succeeds and the secrets simply never appear. Always check
`/var/lib/opnix/secrets/` after the first deploy rather than trusting a green build.

## Bootstrap

Once per machine, before any secret will resolve.

### macOS

```sh
sudo install -m 0600 -o root -g wheel /dev/null /etc/opnix-token
sudo $EDITOR /etc/opnix-token
```

Then provision without waiting for a rebuild:

```sh
sudo launchctl kickstart -k system/org.nixos.opnix-secrets
tail /var/log/opnix-secrets.log   # expect "Successfully processed N secrets"
```

### NixOS

Same file, different group, since a fresh NixOS host has no `wheel`:

```sh
sudo install -m 0600 -o root -g root /dev/null /etc/opnix-token
sudo $EDITOR /etc/opnix-token
```

From a laptop, without an editor on the box:

```sh
op read "op://<vault>/<service-account-item>/credential" \
  | ssh root@<host> 'install -m 0600 /dev/stdin /etc/opnix-token'
```

Then:

```sh
systemctl restart onepassword-secrets
ls -l /var/lib/opnix/secrets/
```

### `opnix token set`

The tool's own command does the same thing:

```sh
sudo opnix token set
```

It needs the `opnix` binary, which arrives with the config. On a brand-new host,
either write the file directly, or deploy once (it no-ops without a token), set the
token, and deploy again.

## Declaring a Secret

```nix
services.onepassword-secrets.secrets.tailscaleAuthKey = {
  reference = "op://<vaultID>/<itemID>/<field>";
  owner = "root";
  mode = "0600";
};

services.tailscale.authKeyFile = "/var/lib/opnix/secrets/tailscaleAuthKey";
```

- Reference by **ID**, since names change and IDs do not
- A shared item with one field per host keeps auth keys together:
  `op://<vault>/<item>/pi-3`, `op://<vault>/<item>/hetzner-1`

## Building an Env File

opnix writes one value per file, so a service wanting `KEY=value` lines needs them
assembled. `modules/nixos/gatus.nix` is the pattern:

```nix
echo "NTFY_URL=$(cat /var/lib/opnix/secrets/ntfyUrl)" > /run/gatus.env
```

Put it in `ExecStartPre` and point the service's `EnvironmentFile` at `/run`, which
is tmpfs, so the composed file dies with the machine.

## A New Machine

1. Vault and service account for its context, read-only to that vault
2. `/etc/opnix-token` on the box, the only manual step
3. Add the secret and its `reference` to the host config
4. Deploy, then **check `/var/lib/opnix/secrets/`**, because a missing token is silent
