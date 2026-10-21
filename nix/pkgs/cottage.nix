{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "cottage";
  version = "0.8.1";

  src = fetchurl {
    url = "https://github.com/sayanarijit/cottage/releases/download/v${version}/cottage-aarch64-apple-darwin-v${version}.tar.gz";
    hash = "sha256-nOHXZAnzxeV8Odv+v3jB825xl+FOVXuy0C7HAfxgM28=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 ctg $out/bin/ctg
    install -Dm755 ctgx $out/bin/ctgx
    runHook postInstall
  '';

  meta = {
    description = "GitOps tool for managing age-encrypted secrets in git repos";
    homepage = "https://github.com/sayanarijit/cottage";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "ctg";
    platforms = [ "aarch64-darwin" ];
  };
}
