# kanata

Keyboard remapper. Replaces Karabiner-Elements.

## Solution

When kanata is dead (`launchctl print system/org.nixos.kanata` shows `active count = 0` and a non-zero `last exit code`), and a plain `kickstart -k` won't bring it back, fully reload the daemon:

```sh
sudo launchctl bootout system/org.nixos.kanata
sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.kanata.plist
```

`config.kbd` is the keymap, read by the kanata daemon at `~/.config/kanata/config.kbd`.

## One-time host setup (not managed by nix)

Kanata needs a macOS DriverKit system extension that nix-darwin cannot install (signed `.pkg`, framework-level activation, mandatory user approval). Install it once per machine.

### 1. Driver: Karabiner-DriverKit-VirtualHIDDevice v6.2.0

Release page: <https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/tag/v6.2.0>

Pinned to v6.2.0. Kanata's bundled `karabiner-driverkit` crate is built against that release's IPC; pqrs ships protocol changes between minor versions, so newer driver releases are not guaranteed to work. Re-evaluate when kanata's docs bump the supported version.

Download and install:

```sh
curl -fLO https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v6.2.0/Karabiner-DriverKit-VirtualHIDDevice-6.2.0.pkg
open Karabiner-DriverKit-VirtualHIDDevice-6.2.0.pkg
```

Then activate:

```sh
sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager forceActivate
```

### 2. Approve the system extension

`System Settings -> General -> Login Items & Extensions -> Driver Extensions` -> toggle on `org.pqrs.Karabiner-DriverKit-VirtualHIDDevice`.

Verify:

```sh
sudo launchctl list | grep org.pqrs
# expect: org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon
```

### 3. Grant kanata Input Monitoring + Accessibility

```sh
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
```

Add `/run/current-system/sw/bin/kanata` (resolve the symlink with `readlink -f` if the picker rejects it) to both panes. If kanata gets attributed to Terminal instead of itself, add the binary manually via the `+` button. Re-add after `darwin-rebuild` rotates the store path if remapping silently breaks.

## Iteration

Edit `home/private_dot_config/kanata/config.kbd` in the chezmoi source, then:

```sh
chezmoi apply
sudo launchctl kickstart -k system/org.nixos.kanata
```

Daemon label is `org.nixos.kanata` (nix-darwin's auto-prefixed default), not upstream's `dev.kanata.kanata`.

## Recovery after macOS update

Symptom: `kanata.log` loops `driver connected: true / connected / driver connected: false`. Running kanata manually may also show `IOHIDDeviceOpen error: (iokit/common) not permitted`. TCC rows can still report the permissions as granted while the kernel check fails.

What worked (root cause not isolated — try in order, restart the daemon between steps):

1. Re-toggle kanata in `Privacy > Accessibility` (off then on, or remove + re-add via `+`).
2. `sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager forceActivate`
3. Same as 1 for `Privacy > Input Monitoring`.

Kick after each: `sudo launchctl kickstart -k system/org.nixos.kanata`. The launchd log only prints the loop; for real errors, `bootout` and run the binary in the foreground.

## Recovery after sleep/wake

Symptom: kanata is still running (`launchctl list | grep kanata` shows it alive, no crash in `/var/log/kanata.log`), but remapping silently stopped after the machine woke from sleep. The log ends with a normal `driver connected: true` at the wake timestamp and then goes quiet — the VHID socket reconnected but kanata's IOHID grab on the physical keyboards did not survive the wake.

Confirm by checking the unified log for a wake event near the time remapping died:

```sh
log show --predicate 'eventMessage CONTAINS "System Wake"' --last 2h
```

Fix (guessed; VHID daemon side first):

```sh
sudo launchctl kickstart -k system/org.nixos.karabiner-vhid-daemon
sudo launchctl kickstart -k system/org.nixos.kanata
```

If only the kanata kickstart is needed, the bug is purely on kanata's IOHID side and the VHID restart is redundant. If neither helps, fall back to the macOS-update recovery steps above.

## Removing the driver

```sh
sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager deactivate
sudo /Library/Application\ Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Resources/uninstall.sh
```
