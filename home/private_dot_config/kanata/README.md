# kanata

Keyboard remapper. Replaces Karabiner-Elements.

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

(nixpkgs kanata 1.11.0 does not ship the `--macos-request-permissions` flag upstream documents.)

Add `/run/current-system/sw/bin/kanata` (resolve the symlink with `readlink -f` if the picker rejects it) to both panes. If kanata gets attributed to Terminal instead of itself, add the binary manually via the `+` button. Re-add after `darwin-rebuild` rotates the store path if remapping silently breaks.

## Iteration

Edit `home/private_dot_config/kanata/config.kbd` in the chezmoi source, then apply and restart the daemon:

```sh
chezmoi apply ~/.config/kanata/config.kbd
sudo launchctl kickstart -k system/org.nixos.kanata
```

Daemon label is `org.nixos.kanata` (nix-darwin's auto-prefixed default), not upstream's `dev.kanata.kanata`.

Validate the config without restarting the daemon:

```sh
kanata --cfg ~/.config/kanata/config.kbd --check
```

Check daemon status (running, last exit code, last fork PID):

```sh
sudo launchctl print system/org.nixos.kanata | head -20
sudo launchctl print system/org.nixos.karabiner-vhid-daemon | head -20
```

## Logs

Both daemons write stdout and stderr to `/var/log` (paths set in `nix/modules/darwin/kanata.nix`):

| Daemon                                | Log path                            |
| ------------------------------------- | ----------------------------------- |
| kanata                                | `/var/log/kanata.log`               |
| Karabiner VirtualHID userspace daemon | `/var/log/karabiner-vhid-daemon.log`|

Tail them:

```sh
sudo tail -f /var/log/kanata.log
sudo tail -f /var/log/karabiner-vhid-daemon.log
```

Common signals in `kanata.log`:

- `process unmapped keys: false` and `entering the processing loop` on a clean start
- `connect_failed asio.system:2`: the userspace VHID daemon isn't running. Check `karabiner-vhid-daemon.log` and verify the system extension is active (`systemextensionsctl list | grep pqrs`)
- Parse errors point at the offending line in `config.kbd`; `kanata --cfg ... --check` produces the same diagnostics without touching the running daemon

## Caps lock LED stuck on

Kanata intercepts `caps` before macOS sees it, so the LED never toggles. No kanata-side config for this. Unload, press caps physically, reload:

```sh
sudo launchctl bootout system/org.nixos.kanata
# press caps once
sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.kanata.plist
```

## Removing the driver

```sh
sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager deactivate
sudo /Library/Application\ Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Resources/uninstall.sh
```
