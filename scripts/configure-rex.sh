#!/bin/sh

# Writes Rex's settings with defaults. Safe to run from inside Rex: DOT-225 found
# that a write has no effect on the running app, so they apply at its next start.
set -eu

domain=com.superlogical.rex
themes="$(dirname "$0")/../config/rex/custom-themes.json"

defaults write "$domain" rex.developer-mode-enabled -bool true
defaults write "$domain" RexAppUpdateChannel snapshot
defaults write "$domain" rex.client.remoteControl -bool true
defaults write "$domain" rex.agents.names-sessions -bool false

defaults write "$domain" Workspace.appIconVisibility dockOnly
defaults write "$domain" Workspace.paneDensity compact
defaults write "$domain" Workspace.tabStyle vertical
defaults write "$domain" Workspace.terminalStartupCommand "$HOME/.config/rex/startup.sh"

# Key names from the app binary, and the size's type is a guess. See DOT-227.
defaults write "$domain" Workspace.terminalFontName "Maple Mono Normal NF"
defaults write "$domain" Workspace.terminalFontPointSize -float 24

# Exported from an import of config/rex/themes/, so these IDs are fixed on every Mac.
defaults write "$domain" Workspace.customThemes -data "$(xxd -p "$themes" | tr -d '\n')"
defaults write "$domain" Workspace.darkThemeID custom-5618B6EC-9265-4408-942B-CBBAC26BF558
defaults write "$domain" Workspace.lightThemeID custom-4C812174-2DEA-4226-B8C3-3EC827D673E6

echo "Rex settings written. They apply the next time Rex starts."
