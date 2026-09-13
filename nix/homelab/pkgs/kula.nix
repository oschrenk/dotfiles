{ lib
, stdenvNoCC
, fetchurl
, gzip
}:

stdenvNoCC.mkDerivation rec {
  pname = "kula";
  version = "0.18.8";

  src = fetchurl {
    url = "https://github.com/c0m4r/kula/releases/download/${version}/kula-linux-${version}-arm64.gz";
    hash = "sha256-RvsmYQSnhG+EmwxkzQkEmX4UDR1fFo8fTrXsavASruY=";
  };

  nativeBuildInputs = [ gzip ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    gzip -dc $src > kula
    install -Dm755 kula $out/bin/kula
    runHook postInstall
  '';

  meta = {
    description = "Lightweight, self-contained Linux server monitoring tool";
    homepage = "https://github.com/c0m4r/kula";
    license = lib.licenses.agpl3Only;
    mainProgram = "kula";
    platforms = [ "aarch64-linux" ];
  };
}
