{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.vale
    # Language server, for the nvim integration in nvim/lsp/vale-ls.lua. It
    # shells out to vale, and reads the same config as the CLI.
    pkgs.vale-ls
  ];

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
    Packages = https://github.com/JMill/deslop/releases/download/v0.3.0/Deslop.zip, https://github.com/tbhb/vale-ai-tells/releases/download/v1.31.0/ai-tells.zip, https://github.com/tbhb/vale-ai-tells/releases/download/v1.31.0/ai-tells-commits.zip, https://github.com/Syntaf/vale-llm-slop/releases/download/v0.1.0/STE.zip

    MinAlertLevel = warning

    [formats]
    COMMIT_EDITMSG = md

    # Leading **/ so the section matches however the path arrives: bare from a
    # git hook, .git/COMMIT_EDITMSG from the repo root, or absolute, which is
    # what vale-ls hands over and what a listed spelling silently misses.
    [**/COMMIT_EDITMSG]
    BasedOnStyles = ai-tells-commits, Local

    [*.md]
    # Deslop.*, ai-tells.* and STE.* are remote, from the Packages above.
    # Deslop and ai-tells hunt AI tells; STE constrains grammar. They overlap
    # on vocabulary and almost nowhere else.
    BasedOnStyles = Deslop, ai-tells, STE

    ai-tells.FillerIntensifier = NO # eg. "a single writer"
    ai-tells.MicDrop = NO # eg "No auth."
    ai-tells.NegatedObject = NO

    # POS-tagged, and 92% of its hits here are artifacts. A menu path reads as
    # a noun stack, so one "System Settings > Privacy & Security > Full Disk
    # Access" line raises four alerts. Worse, it clashes head-on with rumdl
    # MD063 style = "title-case": title case makes the tagger read every heading
    # word as a proper noun, so "Time Series Aggregation Functions" is a noun
    # cluster to vale and mandatory to rumdl. ai-tells.NounString covers the
    # prose case without either failure.
    STE.NounClusters = NO
    # Not the ASD dictionary, which is copyright. Plain-English swaps that
    # Deslop.Substitutions and ai-tells.FormalRegister already make.
    STE.Dictionary = NO
  '';

  # Local style, not from Packages. StylesPath resolves next to the symlinked
  # .vale.ini, and `vale sync` only rewrites the directories it downloaded, so a
  # style dir named for no package is left alone.
  #
  # ai-tells-commits' own CommitAttribution already rejects `Co-Authored-By:
  # Claude` and noreply@anthropic.com. It does not know about `Claude-Session:`,
  # which is a session URL an agent may append on its own rather than through the
  # `attribution` setting, so the setting cannot suppress it. Caught here instead.
  xdg.configFile."vale/.vale/styles/Local/CommitSessionLink.yml".text = ''
    ---
    extends: existence
    message: "Agent session trailer: '%s'. Strip it. A commit message records the change; a link into a private chat transcript is unreadable to everyone else and dead once the session is gone."
    level: error
    # Scope raw so a markdown autolink node cannot hide the URL from the scan,
    # matching how CommitAttribution handles <noreply@anthropic.com>.
    #
    # (?m) on the anchored alternatives is load-bearing. Vale hands the whole
    # message to the regex as one string, so a bare ^ only ever matches the
    # subject line and a trailer at the bottom goes unreported. Verified: without
    # it, a message ending in `Claude-Session: abc123` and no URL passes clean.
    scope: raw
    raw:
      - '(?:'
      - '(?im)^Claude-Session:'
      - '|(?i)claude\.ai/code/session_'
      - '|(?im)^Session-Link:'
      - ')'
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
