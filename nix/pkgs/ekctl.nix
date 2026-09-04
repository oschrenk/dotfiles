{ lib
, stdenvNoCC
, fetchurl
}:

stdenvNoCC.mkDerivation rec {
  pname = "ekctl";
  version = "1.8.0";

  # Upstream ships one prebuilt universal binary (arm64 + x86_64), so there is
  # no Swift build here and no per-architecture split. The hash is upstream's
  # own published .sha256 for the tarball, converted to SRI.
  src = fetchurl {
    url = "https://github.com/schappim/ekctl/releases/download/v${version}/ekctl-v${version}.tar.gz";
    hash = "sha256-TjgxQVTn33nH4+qkj2MwaZrSpoCK4DPZvXUQdAeHFGo=";
  };

  # The tarball holds the bare binary with no enclosing directory.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 ekctl $out/bin/ekctl
    runHook postInstall
  '';

  meta = {
    description = "Native macOS CLI for Calendar events and Reminders via EventKit, with JSON output";
    homepage = "https://github.com/schappim/ekctl";
    # MIT, stated in the README's License section. There is no LICENSE file, so
    # the GitHub API's license endpoint reports none — read the README, not that.
    license = lib.licenses.mit;
    mainProgram = "ekctl";
    platforms = lib.platforms.darwin;
  };
}
