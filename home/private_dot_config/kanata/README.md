# kanata

Keyboard remapper. Replaces Karabiner-Elements.

`config.kbd` is the keymap, read by the kanata daemon at `~/.config/kanata/config.kbd`.

## One-time host setup (not managed by nix)

Kanata needs a macOS DriverKit system extension that nix-darwin cannot install (signed `.pkg`, framework-level activation, mandatory user approval). Install it once per machine.

### 1. Driver: Karabiner-DriverKit-VirtualHIDDevice v6.2.0

Release page: <https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/tag/v6.2.0>

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
# expect: org.pqrs.Karabiner-DriverKit-VirtualHIDDevice-<hex>  (the dext)
```

**Caveat (upstream docs are wrong here)**: kanata's [setup-macos.md §2](https://github.com/jtroo/kanata/blob/main/docs/setup-macos.md#2-install-karabiner-driverkit-virtualhiddevice) says to expect `org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon` listed at this point. That holds only when Karabiner-Elements is also installed (KE ships the userspace daemon's LaunchDaemon plist). On a KE-free, standalone v6.2.0 install, the `.pkg` ships zero plists, the daemon never starts, and kanata flaps with `connect_failed asio.system:2`. See [jtroo/kanata#1264](https://github.com/jtroo/kanata/issues/1264). The nix-darwin module compensates by managing the daemon itself as `launchd.daemons.karabiner-vhid-daemon` (label `org.nixos.karabiner-vhid-daemon`).

### 3. Grant kanata Input Monitoring + Accessibility

```sh
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
```

(nixpkgs kanata 1.11.0 does not ship the `--macos-request-permissions` flag upstream documents.)

Add `/run/current-system/sw/bin/kanata` (resolve the symlink with `readlink -f` if the picker rejects it) to both panes. If kanata gets attributed to Terminal instead of itself, add the binary manually via the `+` button. Re-add after `darwin-rebuild` rotates the store path if remapping silently breaks.

## Iteration

Edit `home/private_dot_config/kanata/config.kbd` in the chezmoi source, then:

```sh
chezmoi apply
sudo launchctl kickstart -k system/org.nixos.kanata
```

Daemon label is `org.nixos.kanata` (nix-darwin's auto-prefixed default), not upstream's `dev.kanata.kanata`.

## Removing the driver

```sh
sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager deactivate
sudo /Library/Application\ Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Resources/uninstall.sh
```
