# `msgvault`

`msgvault` archives mail for offline search.
Its Google credentials live in the login Keychain, never as files in `~/.config/msgvault`.
`nix/modules/home/msgvault/config.toml` points `client_secrets_command` and `[oauth.tokens]` at `msgvault-token`, a wrapper around `/usr/bin/security`.

## Where Things Live

- The 1Password vault `msgvault` holds the source copies, one item per source.
  The Google OAuth client is the item `Google OAuth`, field `client_secret.json`.
- The login Keychain holds the runtime copies.
  The client secret is under service `msgvault-client-secret`.
  Each OAuth token is under service `msgvault-token`, or `msgvault-token:<namespace>` for a separate Google Contacts grant, with the account address as the account.
- `msgvault-token` stores each value hex-encoded, so `security -w` hands back the exact bytes.

## Setup on a New Mac

Run these after `task nix:rebuild:darwin`, so that `msgvault-token` is on the `PATH`.

1. Copy the client secret into the Keychain: `op read "op://msgvault/Google OAuth/client_secret.json" | msgvault-token set-client-secret`
2. Check it: `msgvault-token client-secret | jq -e .installed >/dev/null && echo ok`
3. Add the Gmail account read-only: `msgvault add-account <address> --readonly`

Step 3 opens a browser.
Google warns that it has not verified the app, because the OAuth client in project `cli-gmail-auth-msgvault` is in production but unverified.
Select Advanced, then go on to the app.
Approve read access only, because Google cannot narrow access it has granted.

## Google Console Setup

The OAuth client is a Desktop client in project `cli-gmail-auth-msgvault`.
It is in production, and Google never verified it.
Publishing removes the 7-day expiry that Google puts on refresh tokens in Testing.

- Before Audience accepts "Publish app", Branding needs an app name, a support email, a home page URL and a privacy policy URL.
  The Branding page does not mark the two URLs.
- Google accepts only URLs on an authorized domain, so `github.com` does not work.
  Both URLs point to `https://oschrenk.dev`, and `oschrenk.dev` is the authorized domain.
- Do not submit for verification.
  Google classes Gmail scopes as restricted, so verification means an annual security assessment.

## Expected Warnings

These warnings appear, and none of them blocks use:

- Audience, on publishing: the dialog says that the app becomes "available to any user with a Google Account".
  Anyone else would reach only their own mailbox, never this one.
- Audience, after publishing: the page says that the app "requires verification".
  The publishing status still shows "In production".
- Data Access: the page calls the data access "not verified", and the Gmail scopes show "Approval required".
- Browser, during `add-account`: the page asks the app developer to submit the app for verification.
  Select Advanced.
  Then go on to the app.
- `~/.config/msgvault/tokens/` holds an empty `<address>.json.lock` file.
  msgvault locks each account there, and the token itself is in the Keychain.

## Inspect and Remove

- List the token accounts: `msgvault-token list`
- Show a record without its value: `security find-generic-password -s msgvault-token -a <address>`
- Remove a token: `MSGVAULT_ACCOUNT=<address> msgvault-token delete`
- Remove the client secret: `security delete-generic-password -s msgvault-client-secret -a google`
- Revoke the grant: <https://myaccount.google.com/permissions>

## Moving the Archive to Another Mac

Use msgvault's backup, not a raw copy of `~/.config/msgvault`.
Upstream `docs/usage/backup.md` names a new Mac as the use case.
A snapshot holds `msgvault.db`, every attachment and `deletions/`, captured at one consistent point.
It holds no Keychain records, so the credentials move separately.

1. On the source Mac, create and check a snapshot: `msgvault backup init --repo <repo> && msgvault backup create --repo <repo> && msgvault backup verify --repo <repo>`
2. Copy the repository to the target Mac: `rsync -a <repo>/ <target>:<repo>/`
3. On the target Mac, restore into an empty directory: `msgvault backup restore --repo <repo> --target <empty-dir>`
4. Move the restored files into `~/.config/msgvault`, next to the `config.toml` symlink: `mv <empty-dir>/* ~/.config/msgvault/`
5. Store the client secret on the target Mac: `op read "op://msgvault/Google OAuth/client_secret.json" | msgvault-token set-client-secret`
6. Store the token on the target Mac, either from the source Mac's record over a secure channel or with a new grant: `msgvault add-account <address> --readonly`
7. Check the archive and sync: `msgvault stats && msgvault sync`

Notes:

- `restore` needs an empty or absent target.
  With `--overwrite` it merges into the target and does not replace it.
- The Gmail sync cursor (`historyId`) lives in the database, so incremental `msgvault sync` keeps working after the move.
- Do not restore with `--include-config`, because `config.toml` comes from Nix.
- The lock files and the record of the running daemon belong to one Mac, and `analytics/` is a cache that msgvault rebuilds.
- A backup repository has no encryption.
- After the move, sync from one Mac only, or the two archives drift apart.
- Instead of a copy, `[remote].url` with an `api_key` sends the CLI to another Mac's daemon.
- Not confirmed: what `add-account` does for an account that already exists, and whether a raw copy is safe while SQLite's `-wal` and `-shm` files exist.
