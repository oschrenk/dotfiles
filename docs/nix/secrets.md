# `opnix`

Secrets pulled from 1Password at activation by [opnix](https://github.com/brizzbuzz/opnix), declared in `modules/darwin/secrets.nix`.

- Secrets are written to the paths their declarations name, such as `~/.local/share/atuin/key`
- One field per file, holding the literal field value
- Nothing secret is in git: the config holds references, which are pointers

## The Token

opnix authenticates with a 1Password **service-account token** at `/etc/opnix-token`.

- **Per machine, and never managed by Nix.**
  A rebuild will not create it
- **One service account per context, scoped read-only to one vault.**
  The Macs' token reads the `Dotfiles` vault alone
- Rotate it on a schedule and give it an expiry

**A missing token fails silently.** opnix logs a warning and exits 0, so the rebuild succeeds and the secrets simply never appear.
`task nix:rebuild:darwin` aborts early on an empty token file for exactly this reason.

## Bootstrap

On a new Mac, `scripts/stage-02-switch.sh` writes the token from 1Password before the first switch.

To write or replace it on a Mac that already runs nix-darwin, then provision without waiting for a rebuild:

```sh
sudo install -m 0600 -o root -g wheel /dev/null /etc/opnix-token
op read --no-newline "op://Personal/Service Accounts/opnix-dotfiles/credentials" | sudo tee /etc/opnix-token >/dev/null
sudo launchctl kickstart -k system/org.nixos.opnix-secrets
tail /var/log/opnix-secrets.log   # expect "Successfully processed N secrets"
```

## Declaring a Secret

References come from `secretspec.toml` by name, through the reader from the `secretspec.nix` flake input:

```nix
secrets.atuinKey = {
  reference = secrets.ref "ATUIN_SYNC_KEY";
  path = "/Users/oliver/.local/share/atuin/key";
  owner = "oliver";
  group = "staff";
  mode = "0400";
};
```

The manifest entry names the 1Password item and field once, and every consumer resolves it by the same name.

## A New Mac

1. A service account for its context, read-only to its vault
2. `/etc/opnix-token`, which `scripts/stage-02-switch.sh` writes from 1Password
3. Add the secret to `secretspec.toml` and its declaration to `modules/darwin/secrets.nix`
4. Deploy, then check the declared paths, because a missing token is silent
