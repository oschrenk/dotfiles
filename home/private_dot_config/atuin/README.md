# atuin

Shell-history sync.

Configuration is owned by Nix Home Manager (`programs.atuin` in
`nix/modules/home/atuin.nix`). The sync key is owned by opnix
(`services.onepassword-secrets.secrets.atuinKey` in
`nix/modules/darwin/secrets.nix`, sourced from 1Password vault `Bootstrap`).

## Restart the daemon

The daemon runs as a per-user launchd agent.

```sh
launchctl kickstart -k gui/$(id -u)/org.nix-community.home.atuin-daemon
```

When to restart:

- After the sync key on disk has been replaced (e.g. opnix re-fetches a rotated
  value from 1Password and the daemon is still holding the old key in memory).
- After `atuin sync` reports a key/auth mismatch but `atuin status` looks sane.

## Check status

```sh
launchctl list | grep atuin
atuin status
atuin sync
```
