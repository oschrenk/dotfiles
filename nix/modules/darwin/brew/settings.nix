{ config, ... }:

# Homebrew global settings and taps.
# Homebrew itself must be installed first (scripts/bootstrap.sh handles this).
# darwin-rebuild switch then manages packages declaratively.
{
  homebrew = {
    enable = true;

    onActivation = {
      # Cleanup strategy for packages no longer declared here:
      #   none      — don't remove anything (safe during migration)
      #   uninstall — remove unlisted packages
      #   zap       — remove unlisted packages + associated data
      cleanup = "zap";
      # Update Homebrew on each activation
      autoUpdate = true;
      # Homebrew 5.1.14 made `brew bundle install --cleanup` interactive by
      # default. `--force-cleanup` restores non-interactive cleanup so the
      # activation does not fail under sudo. Drop once this PR lands (it
      # restructures the invocation into a separate `cleanup` call):
      # https://github.com/nix-darwin/nix-darwin/pull/1774
      extraFlags = [ "--force-cleanup" ];
      # Env vars passed to `brew bundle` during activation. Activation runs
      # under `sudo --user=$USER --set-home env ...`, and `env` strips
      # everything except vars passed explicitly here.
      extraEnv = {
        HOMEBREW_NO_ENV_HINTS = "1";
        HOMEBREW_NO_ANALYTICS = "1";
        HOMEBREW_NO_UPDATE_REPORT_NEW = "1";
        # Without this, brew bundle falls back to ~/.homebrew/trust.json
        # (which doesn't exist) and treats every third-party tap as
        # untrusted. trust.json is rendered declaratively to the XDG path
        # in nix/modules/home/brew-trust.nix.
        XDG_CONFIG_HOME = "/Users/${config.my.personal.username}/.config";
      };
    };

    taps = [
      "darrylmorley/whatcable" # whatcable
      "eddmann/tap" # whatsapp-cli
      "IohannRabeson/tap" # tmignore-rs
      "johannesnagl/tap" # showmd
      "keith/formulae" # reminders-cli
      # Custom SSH clone target. brew's trust check matches taps with custom
      # remotes against the URL, not user/repo — see brew-trust.nix.
      {
        name = "oschrenk/made";
        clone_target = "git@github.com:oschrenk/homebrew-made";
      }
      "oschrenk/personal" # personal casks and fonts
      "txn2/tap" # kubefwd
      "yapstudios/tap" # sfsym
    ];
  };
}
