{ rustPlatform
, fetchFromGitHub
, lib
}:

rustPlatform.buildRustPackage {
  pname = "findbar";
  version = "0.1.0-unstable-2026-09-06";

  # Upstream has no tags or releases yet, so this pins a revision. Upstream's
  # own flake pulls crane, fenix and flake-utils; building here with nixpkgs'
  # rustPlatform keeps all three out of flake.lock.
  src = fetchFromGitHub {
    owner = "KristijanZic";
    repo = "findbar";
    rev = "d18b7467fa319c173a9984564ac715fd644e9552";
    hash = "sha256-yZTnBznzZnR4vUsdIflJiE5g+ohut4abM7TPespE9OU=";
  };

  cargoHash = "sha256-+WSMInxQir6vFUkzX3gOl5uYYn310MiQmWDbSPcCO00=";

  meta = {
    description = "Declarative macOS Finder sidebar favorites manager";
    homepage = "https://github.com/KristijanZic/findbar";
    license = lib.licenses.gpl3Plus;
    mainProgram = "findbar";
    platforms = lib.platforms.darwin;
  };
}
