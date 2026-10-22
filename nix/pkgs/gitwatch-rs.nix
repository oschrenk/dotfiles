{
  rustPlatform,
  fetchFromGitHub,
  lib,
  libgit2,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "gitwatch-rs";
  version = "0.1.1-unstable-2026-10-22";

  # fork: adds --skip-if-merging, --pull-before-push, --network-timeout-seconds
  # and --ssh-key
  src = fetchFromGitHub {
    owner = "oschrenk";
    repo = "gitwatch-rs";
    rev = "cfbdf84a87b08281d383c66d2ee454758da47212";
    hash = "sha256-DHyvmhVf5Ul9+0i/EAt/BZN2QLkuqr1DgRcObGa6gB0=";
  };

  cargoHash = "sha256-ux2hToHJPefaAtxyXLji0FLgamCZp/xlELNJcq17naI=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    libgit2
  ];

  # use system libs from buildInputs rather than vendored copies
  env = {
    LIBGIT2_NO_VENDOR = 1;
    OPENSSL_NO_VENDOR = 1;
  };

  # tests need network or fixtures we haven't set up
  doCheck = false;

  meta = {
    description = "Watch a git repo and automatically commit changes";
    homepage = "https://github.com/croissong/gitwatch-rs";
    license = lib.licenses.mit;
    mainProgram = "gitwatch";
  };
}
