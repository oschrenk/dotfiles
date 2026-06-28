{ rustPlatform
, fetchFromGitHub
, lib
}:

rustPlatform.buildRustPackage rec {
  pname = "firemark";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "Vitruves";
    repo = "firemark";
    tag = "v${version}";
    hash = "sha256-rvczHSbyK8Xs9M0tq8cMgLH6l2RssdTZ7ovuKWyp9A0=";
  };

  cargoHash = "sha256-uzoU5m7gPJlhVeeF2sH1bY3RaC2SAES1DzS61ML0bTI=";

  # tests want fixtures we haven't set up
  doCheck = false;

  meta = {
    description = "Fast watermarking CLI for images and PDFs";
    longDescription = ''
      A fast, single-binary watermarking tool for images and PDFs, built in
      Rust. Overlays traceable, tamper-evident marks (e.g. recipient and
      purpose) so documents shared for identity verification — IDs, pay stubs,
      tax notices — cannot be reused for fraud. Supports 17 visual styles,
      cryptographic filigrane patterns that resist editing, and batch
      processing of entire folders.
    '';
    homepage = "https://github.com/Vitruves/firemark";
    license = lib.licenses.mit;
    mainProgram = "firemark";
  };
}
