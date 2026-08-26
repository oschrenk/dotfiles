# Karabiner-Elements. The app is the karabiner-elements cask; this module only
# seeds its config on a machine that does not have one yet.
# Migrated from chezmoi (home/private_dot_config/private_karabiner/).
{ lib, ... }:
{
  # karabiner.json is written by the Karabiner-Elements GUI, so nothing else can
  # own it. chezmoi tried, and the two had already disagreed: the live file had
  # `global.show_in_menu_bar: false` and the chezmoi copy did not, so an apply
  # would have switched the menu bar icon back on.
  #
  # Copied rather than symlinked, and only when the file is absent. That makes a
  # new machine reproducible without ever reverting a setting on this one, since
  # the branch is dead the moment the file exists.
  #
  # Consequence to accept: the committed copy goes stale as GUI settings change.
  # Refresh it with a plain `cp` when that matters. A stale seed does nothing
  # until the next new machine, which is the difference from a stale chezmoi
  # source.
  home.activation.karabinerSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f="$HOME/.config/karabiner/karabiner.json"
    if [ ! -e "$f" ]; then
      run mkdir -p "$(dirname "$f")"
      run cp ${./karabiner/karabiner.json} "$f"
      run chmod 600 "$f"
    fi
  '';
}
