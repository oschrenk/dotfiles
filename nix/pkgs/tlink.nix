{ rustPlatform
, fetchFromGitHub
, lib
, openssl
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "tlink";
  # Tracking upstream main: no tagged release past 0.1.4 at time of writing.
  # Bump rev + hash to update; version string is informational.
  version = "0.1.4-unstable-2026-06-02";

  src = fetchFromGitHub {
    owner = "ahnopologetic";
    repo = "tlink";
    rev = "d66ae1bb795f93e56e0406986df83537fa2f08d4";
    hash = "sha256-7+NkkL3XT60auBed5quP+xMym35pLa7ZvgtDP3pdMZk=";
  };

  cargoHash = "sha256-YrcSoRLkvYZTFfeCpyAaGXXYT01dZczr79wsE9rTQSE=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  # Cargo.toml hardcodes the `vendored` feature on the openssl crate. This env
  # var tells openssl-sys' build script to ignore that and link the system
  # OpenSSL from buildInputs instead, avoiding the slow vendored C build.
  env.OPENSSL_NO_VENDOR = 1;

  # Tests need a real tmux + macOS Launch Services; skip in the sandbox.
  doCheck = false;

  meta = {
    description = "tmux:// deeplink CLI for macOS";
    homepage = "https://github.com/ahnopologetic/tlink";
    license = lib.licenses.mit;
    mainProgram = "tlink";
    platforms = lib.platforms.darwin;
  };
}
