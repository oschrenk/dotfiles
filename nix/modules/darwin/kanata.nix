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
#
# macOS TCC permissions (Input Monitoring AND Accessibility):
#   Kanata needs BOTH permissions. They fail one at a time — Input Monitoring
#   first, then Accessibility — so expect to do this dance twice on a fresh
#   binary. TCC tracks permission per binary path, so every store-path change
#   (nixpkgs bump, pin change) means re-granting both.
#
#   Symptoms (daemon respawns ~10s in a loop):
#     [ERROR] failed to open keyboard device(s): kanata needs macOS Input
#             Monitoring permission. ...
#     [ERROR] failed to open keyboard device(s): kanata needs macOS
#             Accessibility permission. ...
#
#   Fix (repeat for each pane as errors appear):
#     1. Open the relevant pane:
#          Input Monitoring:
#            open 'x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent'
#          Accessibility:
#            open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'
#     2. Cases:
#        - "kanata" listed once, off       -> toggle on.
#        - "kanata" listed twice (stale)   -> delete the old entry, leave new on.
#        - "kanata" listed once, on, still failing -> toggle off, then on.
#        - Not listed                       -> click +, add the binary path
#                                              (the daemon's open attempt
#                                               normally registers it; if not,
#                                               add manually).
#     3. sudo launchctl kickstart -k system/org.nixos.kanata
#
#   If kanata still misbehaves after permissions are granted (stuck vhid
#   state, "virtual_hid_keyboard_ready false" loop, ghost device entries),
#   fully cycle the vhid daemon then kick kanata:
#     sudo launchctl bootout system /Library/LaunchDaemons/org.nixos.karabiner-vhid-daemon.plist
#     sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.karabiner-vhid-daemon.plist
#     sudo launchctl kickstart -k system/org.nixos.kanata
#   `kickstart -k` alone often isn't enough for the vhid daemon — its IPC
#   socket under /Library/Application Support/org.pqrs/tmp/rootonly/ can hold
#   stale connection state that only a full bootout/bootstrap clears.
#
#   Finding the current kanata store path (for the System Settings + dialog):
#     sudo launchctl print system/org.nixos.kanata | awk '/^\tprogram =/ {print $3}'
#   That is the exact path TCC matches against. `realpath $(which kanata)`
#   also works but only if the user's PATH has been rehashed since the rebuild.
#
#   `kanata --macos-request-permissions` registers Accessibility silently and
#   exits with no GUI — don't expect a dialog. Input Monitoring registers
#   passively when the daemon attempts IOKit open.
#   `kanata --macos-request-permissions` only registers Accessibility, not
#   Input Monitoring, and exits silently with no GUI — don't expect a dialog.
{ config, pkgs, lib, ... }:
let
  # Pinned to a non-release commit to investigate build-specific issues.
  #
  # BROKEN at this rev (1fd7db6, kanata 1.12.0-prerelease-2):
  #   Bluetooth keyboards are not grabbed. The built-in MacBook keyboard
  #   gets grabbed and remapped correctly, but events from a paired BT
  #   keyboard pass through unmodified. Log shows "keyboard grabbed,
  #   entering event processing loop" with no error, so the failure is
  #   silent from kanata's perspective. Regression vs nixpkgs 1.11.0
  #   (release) where BT grab worked. Lots of macOS grab/diagnostic churn
  #   landed between 1.11.0 and this prerelease (#1989 definputdevices,
  #   #2015 startup diagnostics, #2031 mouse tap relocation, etc.) — one
  #   of those likely introduced the regression.
  #
  # To bump:
  #   1. Update rev.
  #   2. Set hash + cargoDeps.hash to lib.fakeHash, rebuild, and copy the
  #      "got: sha256-..." values from the error.
  # cargoDeps is overridden directly (not via cargoHash) because overrideAttrs
  # doesn't re-thread cargoHash into the vendor derivation built by
  # rustPlatform.buildRustPackage.
  # doInstallCheck is off because versionCheckHook greps for `version` in
  # `kanata --version` output, which still reports the upstream cargo version
  # (e.g. "1.12.0-prerelease-2"), not our git-sha label.
  kanata-pinned =
    let
      kanataSrc = pkgs.fetchFromGitHub {
        owner = "jtroo";
        repo  = "kanata";
        rev   = "1fd7db64a74a5e66a1780dc60e3993e53d9d003f";
        hash  = "sha256-rNlzd0YiXEU4Q0KVJNstKUTD78A0pUP+1q3xjOb9uQc=";
      };
    in
    pkgs.kanata.overrideAttrs (old: {
      version = "git-1fd7db6";
      src = kanataSrc;
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        src = kanataSrc;
        name = "kanata-git-1fd7db6-vendor";
        hash = "sha256-dVQhiEj8izA4lv4lZdLHr6rND8Gm8pvAx6mP6MPK1zk=";
      };
      doInstallCheck = false;
    });
in
{
  environment.systemPackages = [ kanata-pinned ];

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
        "${kanata-pinned}/bin/kanata"
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
