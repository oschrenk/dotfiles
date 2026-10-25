{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  installShellFiles,
}:

stdenvNoCC.mkDerivation rec {
  pname = "aerospace";
  version = "0.5";

  src = fetchurl {
    url = "https://github.com/JasonBates/AeroSpace-Alpha/releases/download/v${version}/AeroSpace-Alpha-v${version}.zip";
    hash = "sha256-mdvOdV6dG+hcbwJ0KKbUnHiZkSqcQjs6J3mOkC95tZ0=";
  };

  nativeBuildInputs = [
    unzip
    installShellFiles
  ];

  # keep the Developer ID signature intact
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R AeroSpace.app $out/Applications/
    install -Dm755 bin/aerospace $out/bin/aerospace
    installManPage manpage/*
    installShellCompletion --cmd aerospace \
      --bash shell-completion/bash/aerospace \
      --fish shell-completion/fish/aerospace.fish \
      --zsh shell-completion/zsh/_aerospace
    runHook postInstall
  '';

  meta = {
    description = "AeroSpace Alpha, AeroSpace with pending upstream fixes merged";
    homepage = "https://github.com/JasonBates/AeroSpace-Alpha";
    license = lib.licenses.mit;
    mainProgram = "aerospace";
    platforms = [ "aarch64-darwin" ];
  };
}
