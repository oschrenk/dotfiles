{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:

rustPlatform.buildRustPackage rec {
  pname = "firemark";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "Vitruves";
    repo = "firemark";
    tag = "v${version}";
    hash = "sha256-JCml0SsicpatYQgLRonRtnCUVa08CEZhq7kUYl5irIg=";
  };

  cargoHash = "sha256-pEq4UfLUvGxTZZBfrodqe5VVSsxJn+UCAXX7brmpeXk=";

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
