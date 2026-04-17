{ ... }:

{
  programs.atuin = {
    enable = true;

    # run atuin daemon as a launchd agent (background sync, faster DB writes, in-memory search index)
    daemon.enable = true;

    # fish config handles keybinds manually via ATUIN_NOBIND
    enableFishIntegration = false;

    settings = {
      # if false, enter and tab both return to shell without executing
      enter_accept = false;

      # possible values: auto, full, compact
      style = "compact";

      # invert UI — put search bar at the top
      invert = true;

      # show help row including version, available updates, keymap hint, and total commands
      show_help = false;

      # filter history recording by regexes (unanchored — match anywhere unless anchored with ^ or $)
      # see https://docs.atuin.sh/configuration/config/#history_filter
      history_filter = [
        # ignore downloading videos
        "^tube"
        "^sideload"
        "^stream"
        "^pad"
        # ignore single char entries
        "^.$"
        # ignore short commands
        "^ls$"
        "^git ap$"
        "^git c$"
        "^git l$"
        "^git s$"
        "^cd$"
      ];

      # filter out secrets from history (AWS keys, GitHub PATs, Slack tokens, Stripe keys, etc.)
      # see https://docs.atuin.sh/configuration/config/#secrets_filter
      secrets_filter = true;

      # exclude directories from history tracking
      # see https://docs.atuin.sh/configuration/config/#cwd_filter
      cwd_filter = [ ];

      # default filter mode when searching (ctrl+r toggles)
      # global: all hosts, sessions, directories
      # host: this host only
      # session: current session only
      # directory: current directory only
      filter_mode = "host";

      # enable sync v2
      # see https://docs.atuin.sh/configuration/config/#sync
      sync.records = true;
    };
  };
}
