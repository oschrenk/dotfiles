{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "atuin";
  version = "18.24.1";

  src = fetchurl {
    url = "https://github.com/atuinsh/atuin/releases/download/v${version}/atuin-aarch64-apple-darwin.tar.gz";
    hash = "sha256-AJTKqlcy6kBP+QV+h6bvHrRacxdDO8OmsGw63wVG6JE=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 atuin $out/bin/atuin
    runHook postInstall
  '';

  meta = {
    description = "Replacement for a shell history which records additional commands context";
    homepage = "https://github.com/atuinsh/atuin";
    license = lib.licenses.mit;
    mainProgram = "atuin";
    platforms = [ "aarch64-darwin" ];
  };
}
