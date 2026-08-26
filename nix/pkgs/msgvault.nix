{ lib
, stdenvNoCC
, fetchurl
}:

let
  version = "0.19.3";
  # Upstream's own flake builds from source and pins Go 1.27.0 as a source
  # build, with no binary cache, so using it would compile Go itself on every
  # bump. These are upstream's release archives, hashes taken from the
  # SHA256SUMS asset of the same release.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/kenn-io/msgvault/releases/download/v${version}/msgvault_${version}_darwin_arm64.tar.gz";
      hash = "sha256-/WOdEr2RRl8K3IPZNGqCULli4vZRm5pDJaiWHTZBqHI=";
    };
    x86_64-darwin = {
      url = "https://github.com/kenn-io/msgvault/releases/download/v${version}/msgvault_${version}_darwin_amd64.tar.gz";
      hash = "sha256-Ez3h/Nfib+i0I+yL3LErvwz/BCJk77XDaJ1Z7A7wChg=";
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "msgvault: no prebuilt archive for ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "msgvault";
  inherit version;

  src = fetchurl source;

  # The archive is a bare binary with no leading directory.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 msgvault $out/bin/msgvault
    runHook postInstall
  '';

  meta = {
    description = "Archive a lifetime of email and chat with offline search and analytics";
    homepage = "https://github.com/kenn-io/msgvault";
    license = lib.licenses.mit;
    mainProgram = "msgvault";
    platforms = lib.attrNames sources;
  };
}
