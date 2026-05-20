{ rustPlatform
, fetchFromGitHub
, lib
}:

rustPlatform.buildRustPackage rec {
  pname = "cottage";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "sayanarijit";
    repo = "cottage";
    tag = "v${version}";
    hash = "sha256-I4vphWQEGjXDhc2MBzWWyRQ/lByLKnLCqgp+dtM3KWU=";
  };

  cargoLock.lockFile = ./cottage.Cargo.lock;

  # tests need network or fixtures we haven't set up
  doCheck = false;

  meta = {
    description = "GitOps tool for managing age-encrypted secrets in git repos";
    homepage = "https://github.com/sayanarijit/cottage";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "ctg";
  };
}
