{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.vale ];

  # Global fallback config. Vale prefers a .vale.ini found by walking up from
  # the file being linted, and only falls back to this one when a project has
  # none of its own. It only looks here when XDG_CONFIG_HOME is set — with the
  # variable unset vale reports "no config file found" rather than probing
  # ~/.config, so anything launched outside the login shell won't see it.
  #
  # StylesPath resolves relative to this symlink, not to its store target, so
  # ~/.config/vale/.vale/styles stays writable for `vale sync`. Local styles
  # dropped in there by hand survive a sync untouched.
  xdg.configFile."vale/.vale.ini".text = ''
    # Prose linting via https://vale.sh

    StylesPath = .vale/styles
    Packages = https://github.com/JMill/deslop/releases/download/v0.3.0/Deslop.zip, https://github.com/tbhb/vale-ai-tells/releases/download/v1.31.0/ai-tells.zip, https://github.com/tbhb/vale-ai-tells/releases/download/v1.31.0/ai-tells-commits.zip

    MinAlertLevel = warning

    [formats]
    COMMIT_EDITMSG = md

    # Both spellings, because git hands the hook one and a direct run takes the other.
    [{COMMIT_EDITMSG,.git/COMMIT_EDITMSG}]
    BasedOnStyles = ai-tells-commits

    [*.md]
    # Deslop.* and ai-tells.* are remote, from the Packages above
    BasedOnStyles = Deslop, ai-tells

    ai-tells.FillerIntensifier = NO # eg. "a single writer"
    ai-tells.MicDrop = NO # eg "No auth."
    ai-tells.NegatedObject = NO
  '';

  # Pull the remote packages down after the config lands, otherwise every rule
  # in Packages is an unknown style until the first manual sync. Stamped with
  # the store path of the rendered config, so this is a no-op on rebuilds that
  # left it alone; a failure (offline, dead release URL) warns instead of aborting
  # the switch.
  home.activation.valeSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    valeStamp="${config.xdg.configHome}/vale/.vale/.synced-from"
    valeWant="${config.xdg.configFile."vale/.vale.ini".source}"
    if [ "$(cat "$valeStamp" 2>/dev/null || true)" != "$valeWant" ]; then
      if [ -z "''${DRY_RUN:-}" ]; then
        if XDG_CONFIG_HOME="${config.xdg.configHome}" ${pkgs.vale}/bin/vale sync; then
          printf '%s\n' "$valeWant" > "$valeStamp"
        else
          warnEcho "vale sync failed — run 'vale sync' by hand once you're online"
        fi
      else
        echo "would run vale sync"
      fi
    fi
  '';
}
