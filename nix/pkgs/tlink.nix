{ rustPlatform
, fetchFromGitHub
, lib
, openssl
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "tlink";
  version = "0.1.5-socket-passthrough";

  # Own fork: adds `?socket=<name>` passthrough so tmux servers on a named
  # socket (`tmux -L <name>`) are reachable from deeplinks and agent hooks.
  src = fetchFromGitHub {
    owner = "oschrenk";
    repo = "tlink";
    rev = "983bb2432e84aff5452c31902ca64c3b0fe9da3a";
    hash = "sha256-usT9lenL8bJPzGdX+mtul4gB7dvLOIteag0pB6Lb6n4=";
  };

  cargoHash = "sha256-aOIcXEQoomLMWs2Cs61nHOzTo1Ch6snyFd3qn/CGaf8=";

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
