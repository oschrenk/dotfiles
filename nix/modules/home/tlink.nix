# tlink: tmux:// deeplink CLI for macOS.
#
# Manual lifecycle steps that nix cannot encode:
#
# After first install, run `tlink setup` once. It is an interactive TUI that
# compiles a minimal TmuxLink.app via Swift and registers the tmux:// URI
# scheme with Launch Services. There is no non-interactive flag upstream
# (cli.rs declares `Setup` as wizard-only), so this can't be wired into a
# HM activation script.
#
# Before removing the package, run `tlink uninstall` to deregister
# TmuxLink.app from Launch Services. Nix has no per-package pre-deletion
# hook (the model is "describe desired state and switch atomically"; the
# previous generation is never queried for cleanup), so this is on you.
{ pkgs, ... }:
{
  home.packages = [ pkgs.tlink ];

  xdg.configFile."tlink/config.toml".source = ./tlink/config.toml;
}
