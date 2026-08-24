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

    # The token lives in the macOS keychain, so nothing secret lands here.
    # Note this makes hosts.yml a read-only store symlink: `gh auth login` and
    # `gh auth switch` can no longer rewrite it.
    hosts."github.com" = {
      user = "oschrenk";
      git_protocol = "ssh";
      users.oschrenk = { };
    };
  };
}
