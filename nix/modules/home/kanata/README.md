# kanata

Keyboard remapper. Replaces Karabiner-Elements.

> Broken right after `task nix-darwin` or a flake update? Do not investigate the
> driver or flake.lock. Go straight to [Recovery after a nix update](#recovery-after-a-nix-update). It is a store-path / TCC re-grant, nothing else.

## Solution

When kanata is dead (`launchctl print system/org.nixos.kanata` shows `active count = 0` and a non-zero `last exit code`), and a plain `kickstart -k` won't bring it back, fully reload the daemon:

```sh
sudo launchctl bootout system/org.nixos.kanata
sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.kanata.plist
```

`config.kbd` is the keymap, read by the kanata daemon at `~/.config/kanata/config.kbd`.

## Recovery after a nix update

This is the single most common breakage. Every `task nix-darwin` that bumps nixpkgs can trigger it.

Symptom: remapping stops working right after a nix update. The daemon still looks alive (`launchctl print system/org.nixos.kanata` shows `state = running`, `active count = 1`) and `kanata.log` looks normal, often looping `virtual_hid_keyboard_ready true`. Nothing in the log says "permission".

Root cause, and what it is NOT: this is NOT a kanata version change and NOT a driver problem. kanata is pinned to a git rev in `nix/modules/darwin/kanata.nix`, and the Karabiner-DriverKit driver is pinned to v6.2.0. Both are stable across the update. `kanata --version` reporting `1.12.0-prerelease-2` is expected (it prints the upstream cargo version of the pinned source), not evidence of an upgrade. What actually changed is the kanata binary's nix store path: a nixpkgs bump rebuilds the base `pkgs.kanata` derivation, so the `overrideAttrs` pin produces a new output hash and a new `/nix/store/...-kanata-.../bin/kanata` path. macOS TCC grants Input Monitoring and Accessibility per exact binary path, so the new path has zero permissions and kanata cannot grab the keyboard.

Do NOT re-diagnose. Do NOT check the driver version, eval unifi-style version comparisons, or diff flake.lock. Run the runbook.

### Runbook (assistant + user, in this exact order)

1. Get the exact path TCC must match, and copy it to the clipboard for the user:

   ```sh
   sudo launchctl print system/org.nixos.kanata | awk '/^\tprogram =/ {print $3}' | tee /dev/tty | pbcopy
   ```

2. Re-grant BOTH permissions for that path, ONE PANE AT A TIME.

   > STOP. Do NOT open two System Settings panes at once. System Settings is a
   > single-window app: it can only show one Privacy pane at a time, and firing
   > a second `open x-apple.systempreferences:...` URL just navigates the same
   > window away from the first pane. Never batch the two `open` commands.
   > Open Accessibility, WALK THE USER THROUGH IT, and WAIT for them to confirm
   > it is done. Only then open Input Monitoring and walk them through that one.
   > One pane, one confirmation, then the next.

   a. Accessibility (open, then wait for the user):

      ```sh
      open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'
      ```

   b. Input Monitoring (only after the user finishes Accessibility):

      ```sh
      open 'x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent'
      ```

   Grant cases in each pane:
   - listed once, off -> toggle on
   - listed twice (old path plus new) -> delete the stale one, leave the new on
   - listed once, on, still failing -> toggle off then on
   - not listed -> click +, in the file dialog press Cmd+Shift+G, paste the path from step 1, Enter

3. Kick the daemon:

   ```sh
   sudo launchctl kickstart -k system/org.nixos.kanata
   ```

4. Verify remapping actually works. A running daemon is NOT proof. Ask the user to press a remapped key. If it still fails, cycle the vhid daemon then kick again:

   ```sh
   sudo launchctl bootout system /Library/LaunchDaemons/org.nixos.karabiner-vhid-daemon.plist
   sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.karabiner-vhid-daemon.plist
   sudo launchctl kickstart -k system/org.nixos.kanata
   ```

### Clipboard choreography (assistant)

Keep exactly one thing on the clipboard, matched to the user's current step. Copy the store path while the user is on the `+` dialog. Swap to the kickstart command only once both panes are granted. Do not copy the command early; the user adds the path first, then runs the command.

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

Add `/run/current-system/sw/bin/kanata` to both panes. If kanata gets attributed to Terminal instead of itself, add the binary manually via the `+` button. Re-add after `darwin-rebuild` rotates the store path if remapping silently breaks.

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
