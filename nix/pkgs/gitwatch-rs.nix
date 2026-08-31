{ rustPlatform
, fetchFromGitHub
, lib
, libgit2
, openssl
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "gitwatch-rs";
  version = "0.1.1-unstable-2026-08-28";

  # fork: adds --skip-if-merging, --pull-before-push, --network-timeout-seconds
  # and --ssh-key
  src = fetchFromGitHub {
    owner = "oschrenk";
    repo = "gitwatch-rs";
    rev = "0d64562d76717ef91e69276e949183eb89ba8907";
    hash = "sha256-O1Y2Il6cwfCHPHgxauklZmC1GyWSlXKiAX5+SduVu4c=";
  };

  cargoHash = "sha256-P4jcz+SUF+i6Fp95b0px+/1Fnh0l1IoyEaiiK1XDP9o=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl libgit2 ];

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
