{ pkgs, nixpkgs, lib, ... }:
let
  # nixos-raspberrypi bundles nixpkgs April 7 which has unifi 9.5.21 (insecure CVE).
  # Import our nixpkgs input to get a newer, non-insecure unifi and inject it via overlay.
  pkgs' = import nixpkgs {
    inherit (pkgs) system;
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unifi-controller"
      "mongodb"
    ];
  };

  # Pre-built MongoDB 7.0.40 binaries compiled for Raspberry Pi 4 (ARMv8.0, no LSE atomics).
  # Official MongoDB 7.x aarch64 binaries require ARMv8.1+ (LSE) and SIGILL on Pi 4.
  # These community binaries are built with -mcpu=cortex-a72 and work on Pi 4.
  # Source: https://github.com/themattman/mongodb-raspberrypi-binaries
  mongodb-rpi = pkgs.stdenv.mkDerivation rec {
    pname = "mongodb";
    version = "7.0.40";

    src = pkgs.fetchurl {
      url = "https://github.com/themattman/mongodb-raspberrypi-binaries/releases/download/r7.0.40-rpi-unofficial/mongodb.ce.pi4.r7.0.40.tar.gz";
      sha256 = "ebbf873eeee24f2fedf7f418e08d0acd7fd68016ba46a0c6fda18b93fb44e7fa";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];

    # libstdc++ required per upstream README
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.curl
      pkgs.openssl_1_1
    ];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/bin
      install -m755 mongod mongos $out/bin/
    '';

    meta = {
      description = "MongoDB 7.0 for Raspberry Pi 4 (ARMv8.0, no LSE)";
      license = lib.licenses.sspl;
      platforms = [ "aarch64-linux" ];
    };
  };
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "unifi-controller"
    "mongodb"
  ];

  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" ];

  nixpkgs.overlays = [
    (_final: _prev: {
      # Delete this inner overrideAttrs once nixpkgs carries 10.6.101 or newer,
      # and go back to a bare pkgs'.unifi. Check with:
      #   nix eval --raw nixpkgs#unifi.version
      unifi = (pkgs'.unifi.overrideAttrs (_: rec {
        version = "10.6.101";
        src = pkgs'.fetchurl {
          url = "https://dl.ui.com/unifi/${version}/unifi_sysvinit_all.deb";
          hash = "sha256-tauAnCaAt+wiEG7xnHlC8fo0MzjD7tGCkwPZWyzk/dc=";
        };
      }))
      # Remove the "Upgrade to UniFi OS Server" nag modal. Kept as its own layer
      # so that deleting the version pin above does not silently take it along.
      # Patch from thornygravy/unifi-patch-upgrade-nag (MIT), pinned to the
      # revision it was taken from, since main moves and the regex is
      # version-specific. Upstream states it is tested on 10.6.101.
      # https://github.com/thornygravy/unifi-patch-upgrade-nag/blob/f17fbff8ca2192b0ac5f601687648a0c2ae269f4/patch-upgrade-nag.sh
      #
      # Upstream mounts this as a container init script and edits the file in
      # place. The store is read-only, so it runs at build time instead.
      #
      # The trailing context is load-bearing, not decoration: `return n&&r?`
      # appears twice in the bundle, and the other occurrence is an unrelated
      # radio-table expression that must not change. Upstream expresses this as
      # a PCRE lookahead; the capture group below says the same thing in plain
      # sed, byte for byte, and needs nothing added to nativeBuildInputs.
      #
      # A missing pattern fails the build on purpose. The alternative is a quiet
      # no-op that lets the nag return with no signal. The version is pinned by
      # hash anyway, so a bump is already a deliberate edit.
      .overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          swai=$(find $out/webapps/ROOT/app-unifi/react/js -name 'swai.*.js' | head -1)
          [ -n "$swai" ] || { echo "swai bundle not found"; exit 1; }
          grep -qE 'return n&&r\?.{1,30}aF\.Root' "$swai" \
            || { echo "nag pattern not found - UniFi bundle changed"; exit 1; }
          sed -i 's/return n&&r?\(.\{1,30\}aF\.Root\)/return !1\&\&r?\1/' "$swai"
          grep -q 'return !1&&r?' "$swai" || { echo "patch verification failed"; exit 1; }
        '';
      });
      mongodb-7_0 = mongodb-rpi;
    })
  ];

  services.unifi = {
    enable = true;
    openFirewall = true;
    jrePackage = pkgs'.jdk25_headless;
  };

  # First boot on a Pi 4 exceeds the 90s default start timeout (fresh MongoDB
  # init + Spring/Tomcat), failing activation spuriously. Widen the window.
  systemd.services.unifi.serviceConfig.TimeoutStartSec = "5min";

  # openFirewall = true opens 6789/8080/8843/8880/3478/5353/10001 but not 8443.
  # 8443 is the primary HTTPS web UI port.
  networking.firewall.allowedTCPPorts = [ 8443 ];
}
