{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  version = "0.4.0";
  # Upstream publishes prebuilt per-architecture archives, so there is no Rust
  # build here. Hashes are upstream's own, carried over from the brew formula.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/IohannRabeson/tmignore-rs/releases/download/${version}/tmignore-rs_${version}_aarch64.zip";
      hash = "sha256-0oHBsxaBT1oGfNSvVikhuKOlWrcwI8u9oVSDnf4LXuA=";
    };
    x86_64-darwin = {
      url = "https://github.com/IohannRabeson/tmignore-rs/releases/download/${version}/tmignore-rs_${version}_x86-64.zip";
      hash = "sha256-V9TPPHcrYIY4zsUV8iBxe/SPt+yFq7OB8Q9c797ksnw=";
    };
  };
  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "tmignore-rs: no prebuilt archive for ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "tmignore-rs";
  inherit version;

  src = fetchurl source;

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    unzip -q $src
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 tmignore-rs $out/bin/tmignore-rs
    runHook postInstall
  '';

  meta = {
    description = "Makes Time Machine respect .gitignore files";
    homepage = "https://github.com/IohannRabeson/tmignore-rs";
    license = lib.licenses.mit;
    mainProgram = "tmignore-rs";
    platforms = lib.attrNames sources;
  };
}
