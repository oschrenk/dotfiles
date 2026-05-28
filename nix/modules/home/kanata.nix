# Kanata keyboard remapper config (user scope).
#
# The system-level daemon, vhid-daemon, and driver activation guard live
# in nix/modules/darwin/kanata.nix. That module's LaunchDaemon reads the
# config from this absolute path:
#   /Users/<user>/.config/kanata/config.kbd
# Home Manager owns the file at that path (was chezmoi-managed before).
{ ... }:
{
  xdg.configFile."kanata/config.kbd".source = ./kanata/config.kbd;
  xdg.configFile."kanata/README.md".source = ./kanata/README.md;
}
