{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "fusion";
  version = "1.2.1";

  # Upstream's release binary: static Go build (CGO_ENABLED=0, -extldflags -static)
  # with the web UI embedded, so it needs no autoPatchelf or interpreter fixup.
  # On bump, take the hash from the release's checksums.txt and convert it with
  # `nix hash convert --to sri --hash-algo sha256 <hex>`.
  src = fetchurl {
    url = "https://github.com/0x2E/fusion/releases/download/v${version}/fusion-linux-arm64";
    hash = "sha256-XIxjJ7pUy78MyJuSyoU9Eg6pCnHa4tFxDxTRjk71aeQ=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/fusion
    runHook postInstall
  '';

  meta = {
    description = "Lightweight RSS reader";
    homepage = "https://github.com/0x2E/fusion";
    license = lib.licenses.mit;
    mainProgram = "fusion";
    platforms = [ "aarch64-linux" ];
  };
}
