# GitHub CLI. Migrated from chezmoi (home/private_dot_config/gh/).
{ ... }:
{
  programs.gh = {
    enable = true;

    # HM defaults this to true, which would inject a `credential.https://github.com`
    # helper into the git config. We clone over SSH, so keep git untouched.
    gitCredentialHelper.enable = false;

    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };

    # hosts.yml is deliberately left unmanaged. `gh auth login` / `auth switch`
    # rewrite it, and a read-only store symlink would break that. gh keeps it in
    # XDG_CONFIG_HOME rather than its state dir (~/.local/state/gh), but it is
    # an auth ledger, not configuration: the token lives in the macOS keychain
    # and a fresh machine just needs `gh auth login`.
  };
}
