#!/usr/bin/env zsh

set -euo pipefail

current_hostname=$(scutil --get HostName 2>/dev/null || echo "(not set)")
current_local=$(scutil --get LocalHostName 2>/dev/null || echo "(not set)")
current_computer=$(scutil --get ComputerName 2>/dev/null || echo "(not set)")

echo "Current machine names:"
echo "HostName:      $current_hostname"
echo "LocalHostName: $current_local"
echo "ComputerName:  $current_computer"
echo
echo "chezmoi and nix-darwin fall back to LocalHostName if HostName is unset."
echo
echo "Press Enter to keep current values. Type '-' to unset HostName."
echo
read "new_local?LocalHostName [$current_local]: "
new_local=${new_local:-$current_local}

read "new_computer?ComputerName [$current_computer]: "
new_computer=${new_computer:-$current_computer}

read "new_hostname?HostName [$current_hostname] (leave blank to keep, type '-' to unset): "
new_hostname=${new_hostname:-$current_hostname}

has_changes=false
[[ "$new_local" != "$current_local" ]] && has_changes=true
[[ "$new_computer" != "$current_computer" ]] && has_changes=true
[[ "$new_hostname" == "-" || ( "$new_hostname" != "$current_hostname" && "$new_hostname" != "(not set)" ) ]] && has_changes=true

if [[ "$has_changes" == false ]]; then
  echo "No changes made."
  exit 0
fi

echo
echo "Pending changes:"
[[ "$new_local" != "$current_local" ]] && echo "  LocalHostName: $current_local -> $new_local"
[[ "$new_computer" != "$current_computer" ]] && echo "  ComputerName:  $current_computer -> $new_computer"
if [[ "$new_hostname" == "-" ]]; then
  echo "  HostName:      $current_hostname -> (unset)"
elif [[ "$new_hostname" != "$current_hostname" ]]; then
  echo "  HostName:      $current_hostname -> $new_hostname"
fi
echo

read "confirm?Apply? [y/N] "
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "No changes made."
  exit 0
fi

[[ "$new_local" != "$current_local" ]] && sudo scutil --set LocalHostName "$new_local"
[[ "$new_computer" != "$current_computer" ]] && sudo scutil --set ComputerName "$new_computer"
if [[ "$new_hostname" == "-" ]]; then
  sudo scutil --set HostName ""
elif [[ "$new_hostname" != "$current_hostname" && "$new_hostname" != "(not set)" ]]; then
  sudo scutil --set HostName "$new_hostname"
fi

echo "Done."
