{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "socktainer";
  version = "1.6.0";

  src = fetchurl {
    url = "https://github.com/socktainer/socktainer/releases/download/v${version}/socktainer.zip";
    hash = "sha256-MbYdLUbRKMeGv4onOueaZqr4z1W2EC66/jaY6yDlukg=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  # keep the Developer ID signature intact
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 socktainer $out/bin/socktainer
    runHook postInstall
  '';

  meta = {
    description = "Docker-compatible API on top of Apple container";
    homepage = "https://github.com/socktainer/socktainer";
    license = lib.licenses.asl20;
    mainProgram = "socktainer";
    platforms = [ "aarch64-darwin" ];
  };
}
