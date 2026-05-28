{ rustPlatform
, fetchFromGitHub
, lib
, libgit2
, openssl
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "gitwatch-rs";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "croissong";
    repo = "gitwatch-rs";
    tag = "v${version}";
    hash = "sha256-aRkfqiZ3x8XGcLEgXJik5QbK53Ex9Vew0fw/gOkCoxw=";
  };

  cargoHash = "sha256-HmOYPhhkYaU5IA7DOuOHzj5WZ2vwr2WUtlVv/rlqpB8=";

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
