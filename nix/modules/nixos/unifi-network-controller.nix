{ pkgs, nixpkgs, lib, ... }:
let
  # nixos-raspberrypi bundles nixpkgs April 7 which has unifi 9.5.21 (insecure CVE).
  # Import our nixpkgs input to get 10.2.105 and inject it via overlay.
  pkgs' = import nixpkgs {
    inherit (pkgs) system;
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unifi-controller"
      "mongodb"
    ];
  };

  # Pre-built MongoDB 7.0.31 binaries compiled for Raspberry Pi 4 (ARMv8.0, no LSE atomics).
  # Official MongoDB 7.x aarch64 binaries require ARMv8.1+ (LSE) and SIGILL on Pi 4.
  # These community binaries are built with -mcpu=cortex-a72 and work on Pi 4.
  # Source: https://github.com/themattman/mongodb-raspberrypi-binaries
  mongodb-rpi = pkgs.stdenv.mkDerivation rec {
    pname = "mongodb";
    version = "7.0.31";

    src = pkgs.fetchurl {
      url = "https://github.com/themattman/mongodb-raspberrypi-binaries/releases/download/r7.0.31-rpi-unofficial/mongodb.ce.pi4.r7.0.31.tar.gz";
      sha256 = "ad0e4541147eed95e22628d7f069888916b0df882d7f426be1c2b53dbb411bf7";
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
      unifi = pkgs'.unifi;
      mongodb-7_0 = mongodb-rpi;
    })
  ];

  services.unifi = {
    enable = true;
    openFirewall = true;
    jrePackage = pkgs'.jdk25_headless;
  };

  # openFirewall = true opens 6789/8080/8843/8880/3478/5353/10001 but not 8443.
  # 8443 is the primary HTTPS web UI port.
  networking.firewall.allowedTCPPorts = [ 8443 ];
}
