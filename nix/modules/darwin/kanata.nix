# Kanata keyboard remapper LaunchDaemon.
#
# Direct translation of upstream's cfg_samples/kanata.plist into nix-darwin's
# launchd.daemons schema:
#   https://github.com/jtroo/kanata/blob/main/cfg_samples/kanata.plist
#
# Deltas vs upstream:
#   - daemon label: nix-darwin auto-prefixes to org.nixos.kanata
#   - binary path: nix store, not /usr/local/bin
#   - config path: chezmoi-managed at $HOME/.config/kanata/config.kbd
#   - activation guard: hard-fails rebuild if v6.2.0 driver isn't active
#   - karabiner-vhid-daemon: also managed here. Upstream kanata's
#     setup-macos.md assumes Karabiner-Elements is installed and provides
#     the LaunchDaemon plist for the pqrs userspace daemon. The standalone
#     v6.2.0 .pkg ships zero plists, so on a KE-free host kanata flaps with
#     `connect_failed asio.system:2`. Issue jtroo/kanata#1264 covers this.
#     We launch the daemon ourselves to close the gap.
#
# The Karabiner-DriverKit v6.2.0 system extension this daemon talks to is NOT
# managed by nix - it's a one-time host install via signed .pkg. Setup steps
# at ~/.config/kanata/README.md.
{ config, pkgs, lib, ... }:
{
  environment.systemPackages = [ pkgs.kanata ];

  # Hard-fail rebuild if the v6.2.0 driver isn't installed and activated.
  # Runs before launchd reload so the kanata daemon never lands on a host
  # that can't run it.
  system.activationScripts.postActivation.text = lib.mkBefore ''
    if ! /usr/bin/systemextensionsctl list 2>/dev/null \
        | grep -q 'org.pqrs.Karabiner-DriverKit-VirtualHIDDevice.*activated enabled'; then
      echo "ERROR: kanata module is enabled but the Karabiner-DriverKit v6.2.0"
      echo "system extension is not activated."
      echo "See ~/.config/kanata/README.md for one-time host setup."
      exit 1
    fi
  '';

  # pqrs userspace daemon kanata talks to via IPC under
  # /Library/Application Support/org.pqrs/tmp/rootonly/. The v6.2.0 .pkg
  # installs the binary but ships no LaunchDaemon plist; we provide it.
  launchd.daemons.karabiner-vhid-daemon = {
    serviceConfig = {
      ProgramArguments = [
        "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      ];
      UserName = "root";
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/var/log/karabiner-vhid-daemon.log";
      StandardErrorPath = "/var/log/karabiner-vhid-daemon.log";
    };
  };

  # KeepAlive = { SuccessfulExit = false; } preserves kanata's
  # ctrl+space+esc clean-exit shortcut while still respawning on the boot
  # race against the pqrs daemon. Plain KeepAlive = true would clobber the
  # shortcut.
  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.kanata}/bin/kanata"
        "-c"
        "/Users/${config.system.primaryUser}/.config/kanata/config.kbd"
      ];
      UserName = "root";
      RunAtLoad = true;
      KeepAlive = { SuccessfulExit = false; };
      StandardOutPath = "/var/log/kanata.log";
      StandardErrorPath = "/var/log/kanata.log";
    };
  };
}
