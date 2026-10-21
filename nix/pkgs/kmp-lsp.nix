{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "kmp-lsp";
  version = "0.27.0";

  src = fetchurl {
    url = "https://github.com/Hessesian/kmp-lsp/releases/download/v${version}/kmp-lsp-darwin-aarch64.tar.gz";
    hash = "sha256-6P0iDbZI+Sf+ytSodFOXwPyc5s0uweWsSEUflwBl/kA=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 kmp-lsp $out/bin/kmp-lsp
    install -Dm755 kmp-jar-indexer $out/bin/kmp-jar-indexer
    runHook postInstall
  '';

  meta = {
    description = "Fast, low-memory LSP server for Kotlin, Java, and Swift (no JVM required)";
    homepage = "https://github.com/Hessesian/kmp-lsp";
    license = lib.licenses.mit;
    mainProgram = "kmp-lsp";
    platforms = [ "aarch64-darwin" ];
  };
}
