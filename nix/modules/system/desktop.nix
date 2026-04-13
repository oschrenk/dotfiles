{ ... }:

# https://github.com/nix-darwin/nix-darwin/blob/master/modules/system/defaults/dock.nix
{
  system.defaults.dock = {
    # Hot corners — "Requires killall Dock to take effect"
    # 0  : noop
    # 2  : Mission Control
    # 3  : Application Windows
    # 4  : Desktop
    # 5  : Start screen saver
    # 6  : Disable screen saver
    # 7  : Dashboard
    # 10 : Put Display to sleep
    # 11 : Launchpad
    # 12 : Notification Center
    # 13 : Lock Screen
    # 14 : Quick Note
    wvous-tl-corner = 2; # Mission Control
    wvous-tr-corner = 2; # Mission Control
    wvous-bl-corner = 4; # Desktop
    wvous-br-corner = 5; # Start screen saver
  };
}
