{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "fusion";
  version = "1.2.1";

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
