{ lib
, stdenvNoCC
, fetchurl
, unzip
}:

let
  version = "0.3.12";
  # Upstream publishes prebuilt per-architecture archives, so there is no Rust
  # build here. Hashes are upstream's own, carried over from the brew formula.
  sources = {
    aarch64-darwin = {
      url = "https://github.com/IohannRabeson/tmignore-rs/releases/download/${version}/tmignore-rs_${version}_aarch64.zip";
      hash = "sha256-0RQdh/xQj479Ne/D7+hGyaaYg2ejeI3Ocs91c+Lb0ws=";
    };
    x86_64-darwin = {
      url = "https://github.com/IohannRabeson/tmignore-rs/releases/download/${version}/tmignore-rs_${version}_x86-64.zip";
      hash = "sha256-97qXhnCtP15/YJMqJURSIHrUInBXzIH1iyjIwNSvB4Y=";
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
