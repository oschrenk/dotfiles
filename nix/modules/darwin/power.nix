# Sleep on battery, stay awake on charger.
#
# `disablesleep` is the only pmset setting that keeps a lid-closed MacBook awake
# with no external display attached, and it has no per-source form. `pmset -b
# disablesleep 1` exits 0 but writes SystemPowerSettings.SleepDisabled, the
# system-wide key — the `-b` is accepted and ignored. So a one-shot
# `pmset -a disablesleep 1` at activation also pins the machine awake on battery,
# and no declarative option can fix that. This daemon follows the power source
# and flips the setting on each change.
#
# nix-darwin's own `power.sleep.*` is not a substitute here on two counts: it goes
# through `systemsetup`, which writes only the AC profile and swallows its errors
# (nix-darwin#1850), and even the per-source rewrite in nix-darwin#1767 (open and
# conflicted since 2026-05) covers only the pmset timers, never `disablesleep`.
# The raw pmset calls below stay raw for that reason.
{ lib, ... }:

{
  launchd.daemons.sleep-on-battery = {
    # `pmset -g pslog` prints the current source immediately, then a line on every
    # change, and it line-buffers through a pipe. So RunAtLoad settles the initial
    # state and the loop handles the rest without polling.
    script = ''
      /usr/bin/pmset -g pslog | while IFS= read -r line; do
        case "$line" in
          *"Now drawing from 'AC Power'"*) /usr/bin/pmset -a disablesleep 1 ;;
          *"Now drawing from 'Battery Power'"*) /usr/bin/pmset -a disablesleep 0 ;;
        esac
      done
    '';

    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      StandardErrorPath = "/var/log/sleep-on-battery.log";
    };
  };

  # The daemon decides whether sleep is allowed at all. These decide when it
  # happens once it is allowed. `sleep 0` on charger is belt-and-braces next to
  # disablesleep; the battery timers are the ones that do the work.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    /usr/bin/pmset -b sleep 10 displaysleep 2 disksleep 10
    /usr/bin/pmset -c sleep 0 displaysleep 10 disksleep 0
  '';
}
