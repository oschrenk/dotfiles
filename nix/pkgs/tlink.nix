{ rustPlatform
, fetchFromGitHub
, lib
, openssl
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "tlink";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "ahnopologetic";
    repo = "tlink";
    rev = "v${version}";
    hash = "sha256-SiVRE5gWNXtHR2+ovfRwKjLBdrzuxz/luAvcYEt8oHQ=";
  };

  cargoHash = "sha256-YrcSoRLkvYZTFfeCpyAaGXXYT01dZczr79wsE9rTQSE=";

  # Strip the post-switch tmux status-bar toast (`tlink → <session>`).
  # Upstream has no flag for it; see patch header for details.
  patches = [ ./tlink-no-toast.patch ];

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
