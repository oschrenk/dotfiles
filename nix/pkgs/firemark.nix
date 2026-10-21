{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "firemark";
  version = "0.1.4";

  src = fetchurl {
    url = "https://github.com/Vitruves/firemark/releases/download/v${version}/firemark-v${version}-aarch64-apple-darwin.tar.gz";
    hash = "sha256-uFgMTzgQDtUoUsspRGiQT9Hvhcwl41/8Lp6iH5x2ODo=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 firemark $out/bin/firemark
    runHook postInstall
  '';

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
    platforms = [ "aarch64-darwin" ];
  };
}
