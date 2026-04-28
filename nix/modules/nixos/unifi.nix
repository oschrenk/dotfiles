{ pkgs, nixpkgs, lib, ... }:
let
  # nixos-raspberrypi bundles nixpkgs April 7 which has unifi 9.5.21 (insecure CVE).
  # Import our nixpkgs input to get 10.2.105 and inject it via overlay.
  pkgs' = import nixpkgs {
    inherit (pkgs) system;
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unifi-controller"
    ];
  };

  # mongodb-7_0 in the old nixpkgs compiles from source and OOMs on the Pi.
  # Use pre-built aarch64 binaries from MongoDB's download servers instead,
  # following the same pattern as pkgs.mongodb-ce.
  mongodb-7_0-bin = pkgs.stdenv.mkDerivation {
    pname = "mongodb-7_0-bin";
    version = "7.0.31";
    src = pkgs.fetchurl {
      url = "https://fastdl.mongodb.org/linux/mongodb-linux-aarch64-ubuntu2204-7.0.31.tgz";
      hash = "sha256-V7fEcvCkDMqkGRM4S33JZKGzzDg3Mda0UoxRmQAU3o4=";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.curl.dev pkgs.openssl.dev (lib.getLib pkgs.stdenv.cc.cc) ];
    dontStrip = true;
    installPhase = ''
      install -Dm755 bin/mongod -t $out/bin
      install -Dm755 bin/mongos -t $out/bin
    '';
  };
in
{
  nixpkgs.overlays = [
    (_final: _prev: {
      unifi = pkgs'.unifi;
      mongodb-7_0 = mongodb-7_0-bin;
    })
  ];

  services.unifi = {
    enable = true;
    openFirewall = true;
  };
}
