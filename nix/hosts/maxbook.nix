{
  config,
  pkgs,
  secretspec,
  ...
}:

let
  airbookAgent = ".ssh/airbook-agent.sock";
  openvpnSocket = "/var/run/openvpn-timewax.sock";
  # openvpn requires client auth; the server ignores it and signs in via WEB_AUTH.
  openvpnDummyAuth = pkgs.writeText "openvpn-timewax-auth" "sso\nsso\n";
in

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

  system = {
    # Primary user for user-scoped defaults (e.g. Finder, NSGlobalDomain)
    primaryUser = config.my.personal.username;

    # Set once to the nix-darwin version used when first applying.
    # Never change this — it tells nix-darwin how to handle state migrations.
    # Check current version with: nix run nix-darwin -- --version
    # Or see: https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG.md
    stateVersion = 6;

    activationScripts.postActivation.text = ''
      # Apply system.defaults and CustomUserPreferences without a logout. The -u flag
      # means user-level. Undocumented private-framework binary, so behavior may
      # change between macOS releases. Some prefs still need a killall (Dock,
      # Finder, SystemUIServer, cfprefsd) or app restart to pick up plist changes.
      # Activation runs as root since nix-darwin dropped postUserActivation, so
      # `sudo -u $USER` is what reaches the user's cfprefsd.
      sudo -u ${config.my.personal.username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };

  # MaxBook-specific apps (MacBook Pro with extra peripherals)
  homebrew.casks = [
    "8bitdo-ultimate-software" # controller
    "elgato-control-center" # elgato software to control lights
    # "live-home-3d" # home designer
    "rode-central" # rode companion app (for AI-1)
    "steam" # games
    "tailscale-app" # vpn, mesh network
  ];

  services = {
    # Apple's sshd, because the Tailscale GUI app cannot run a Tailscale SSH
    # server. Full Disk Access goes to /usr/libexec/sshd-keygen-wrapper, a fixed
    # Apple-signed path that survives OS updates, so reading ~/Downloads does not
    # block on a TCC dialog drawn at the console.
    openssh.enable = true;

    # Refuse logins from off the tailnet. ListenAddress cannot do this, because
    # launchd owns the socket under inetdCompatibility and SIP protects ssh.plist.
    # `nobody` has /usr/bin/false as its shell, so it denies every real user.
    # Keys only. UsePAM is on and /etc/pam.d/sshd ends at pam_opendirectory, so
    # keyboard-interactive is a second door to the same account password and has
    # to be closed alongside PasswordAuthentication.
    openssh.extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      AllowUsers nobody
      Match Address 100.64.0.0/10,fd7a:115c:a1e0::/48
        AllowUsers ${config.my.personal.username}
    '';
  };

  home-manager.users.${config.my.personal.username} =
    { config, lib, ... }:
    {
      home.file.".ssh/rc".text = ''
        [ -n "$SSH_TTY" ] || exit 0
        case "$SSH_AUTH_SOCK" in
          "$HOME"/.ssh/agent/*.sshd.*) ln -sf "$SSH_AUTH_SOCK" ~/${airbookAgent} ;;
        esac
      '';

      # Before Host *: ssh keeps the first IdentityAgent it reads.
      programs.ssh.settings.airbook-agent = lib.hm.dag.entryBefore [ "*" ] {
        header = ''Match exec "SSH_AUTH_SOCK=%d/${airbookAgent} /usr/bin/ssh-add -l >/dev/null 2>&1"'';
        IdentityAgent = "~/${airbookAgent}";
      };

      # op-ssh-sign only uses a forwarded agent when SSH_TTY is set, which Rex sessions lack.
      programs.git.signing.signer = lib.mkForce "${pkgs.writeShellScript "git-ssh-sign" ''
        sock="$HOME/${airbookAgent}"
        if SSH_AUTH_SOCK="$sock" /usr/bin/ssh-add -l >/dev/null 2>&1; then
          SSH_AUTH_SOCK="$sock" exec /usr/bin/ssh-keygen "$@"
        fi
        # ~/.ssh/rc relinks only on a TTY login, so after a reconnect the link can point at a dead
        # socket while a live forwarded one sits next to it; relink instead of prompting on this screen
        for s in $(ls -t "$HOME"/.ssh/agent/s.*.sshd.* 2>/dev/null); do
          if SSH_AUTH_SOCK="$s" /usr/bin/ssh-add -l >/dev/null 2>&1; then
            ln -sfn "$s" "$sock"
            SSH_AUTH_SOCK="$s" exec /usr/bin/ssh-keygen "$@"
          fi
        done
        exec /Applications/1Password.app/Contents/MacOS/op-ssh-sign "$@"
      ''}";

      # The binary is the app's Sparkle install; an app update needs an agent restart.
      launchd.agents.rex-server = {
        enable = true;
        config = {
          ProgramArguments = [
            "${config.home.homeDirectory}/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
            "server"
            "run"
            "--tailscale"
            "--tailscale-hostname"
            "olivers-maxbook-rex"
          ];
          EnvironmentVariables = {
            PATH = "/etc/profiles/per-user/${config.home.username}/bin:/usr/bin:/bin";
            SHELL = "/run/current-system/sw/bin/fish";
          };
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/rex-server.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/rex-server.log";
        };
      };
    };

  services.onepassword-secrets.secrets.openvpnProfile = {
    reference = (secretspec.lib.read ../../secretspec.toml).ref "OPENVPN_PROFILE";
    kind = "file";
    path = "/etc/openvpn/timewax.ovpn";
    owner = "root";
    group = "wheel";
    mode = "0400";
  };

  # Held at start: the tunnel stays down until the orchestrator's `task vpn:maxbook:connect`.
  launchd.daemons.openvpn-timewax = {
    script = ''
      exec ${pkgs.openvpn}/bin/openvpn \
        --config ${config.services.onepassword-secrets.secrets.openvpnProfile.path} \
        --ignore-unknown-option max-routes \
        --auth-user-pass ${openvpnDummyAuth} \
        --auth-retry nointeract \
        --setenv IV_SSO webauth \
        --push-peer-info \
        --pull-filter ignore auth-token-user \
        --management ${openvpnSocket} unix \
        --management-client-user ${config.my.personal.username} \
        --management-hold \
        --verb 4
    '';

    serviceConfig = {
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      StandardOutPath = "/var/log/openvpn-timewax.log";
      StandardErrorPath = "/var/log/openvpn-timewax.log";
    };
  };

  # Read by the AuthorizedKeysCommand that nix-darwin already installs.
  users.users.${config.my.personal.username}.openssh.authorizedKeys.keys = [
    config.my.personal.sshKey
  ];

  homebrew.masApps = {
    # "Affinity Designer 2" = 1616831348; # vector editing
    # "Affinity Photo 2" = 1616822987; # raster editing
    # "Affinity Publisher 2" = 1606941598; # book publishing
  };
}
