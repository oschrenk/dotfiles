{ config, ... }:

{
  imports = [
    ../modules/darwin/brew/base.nix
    ../modules/darwin/brew/fonts.nix
    ../modules/darwin/brew/gui.nix
    ../modules/darwin/brew/work.nix
    # Sleep on battery, stay awake on charger. Keeps maxbook reachable over
    # Tailscale while docked with the lid shut.
    ../modules/darwin/power.nix
  ];

  # PAM / Touch ID for sudo (survives macOS upgrades via sudo_local)
  # See: https://github.com/nix-darwin/nix-darwin/pull/1344
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  # MaxBook-specific configuration

  # Apple Silicon — use x86_64-darwin for Intel Macs
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Primary user for user-scoped defaults (e.g. Finder, NSGlobalDomain)
  system.primaryUser = config.my.personal.username;

  # Set once to the nix-darwin version used when first applying.
  # Never change this — it tells nix-darwin how to handle state migrations.
  # Check current version with: nix run nix-darwin -- --version
  # Or see: https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG.md
  system.stateVersion = 6;

  system.activationScripts.postActivation.text = ''
    # Apply system.defaults and CustomUserPreferences without a logout. The -u flag
    # means user-level. Undocumented private-framework binary, so behavior may
    # change between macOS releases. Some prefs still need a killall (Dock,
    # Finder, SystemUIServer, cfprefsd) or app restart to pick up plist changes.
    # Activation runs as root since nix-darwin dropped postUserActivation, so
    # `sudo -u $USER` is what reaches the user's cfprefsd.
    sudo -u ${config.my.personal.username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    # Hold Tailscale SSH off, under a stable name so olivers-maxbook keeps
    # resolving. `--ssh=false` rather than dropping the flag: the preference
    # persists in tailscaled state, so removing it would leave SSH running.
    # Incoming sessions use Apple's sshd instead, for the reason given below.
    ${config.services.tailscale.package}/bin/tailscale set --ssh=false --hostname=olivers-maxbook || true
  '';

  # MaxBook-specific apps (MacBook Pro with extra peripherals)
  homebrew.casks = [
    "8bitdo-ultimate-software" # controller
    "elgato-control-center" # elgato software to control lights
    # "live-home-3d" # home designer
    "rode-central" # rode companion app (for AI-1)
    "steam" # games
  ];

  # Apple's sshd, not Tailscale SSH. A Tailscale SSH session is a child of
  # tailscaled, which holds no Full Disk Access, so reading ~/Downloads blocks
  # forever on a TCC dialog drawn at the console. Full Disk Access goes to
  # /usr/libexec/sshd-keygen-wrapper instead, a fixed Apple-signed path that
  # survives OS and tailscale updates where a nix store path would not.
  # Do not re-enable `tailscale set --ssh` without reading that through.
  services.openssh.enable = true;

  # Refuse logins from off the tailnet. ListenAddress cannot do this, because
  # launchd owns the socket under inetdCompatibility and SIP protects ssh.plist.
  # `nobody` has /usr/bin/false as its shell, so it denies every real user.
  services.openssh.extraConfig = ''
    AllowUsers nobody
    Match Address 100.64.0.0/10,fd7a:115c:a1e0::/48
      AllowUsers ${config.my.personal.username}
  '';

  # Read by the AuthorizedKeysCommand that nix-darwin already installs.
  users.users.${config.my.personal.username}.openssh.authorizedKeys.keys = [
    config.my.personal.sshKey
  ];

  # CLI build, not the GUI cask: only this one can run a Tailscale SSH server.
  # Log in separately with `sudo tailscale up --ssh`.
  services.tailscale.enable = true;

  homebrew.masApps = {
    # "Affinity Designer 2" = 1616831348; # vector editing
    # "Affinity Photo 2" = 1616822987; # raster editing
    # "Affinity Publisher 2" = 1606941598; # book publishing
  };
}
