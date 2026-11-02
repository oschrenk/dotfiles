{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "2025.09.24+grazij.9";
in
stdenvNoCC.mkDerivation {
  pname = "plistwatch";
  inherit version;

  src = fetchurl {
    url = "https://github.com/grazij/plistwatch/releases/download/v${lib.escapeURL version}/plistwatch-${lib.escapeURL version}-darwin-universal.tar.gz";
    hash = "sha256-MV1tQfk2gLEmQ/ZZFwEZVID9Uur2oNbm8As50ovTXEI=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 plistwatch $out/bin/plistwatch
    runHook postInstall
  '';

  meta = {
    description = "Prints plist changes as runnable defaults commands";
    homepage = "https://github.com/grazij/plistwatch";
    license = lib.licenses.mit;
    mainProgram = "plistwatch";
    platforms = lib.platforms.darwin;
  };
}
