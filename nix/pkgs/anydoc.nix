{ lib
, stdenvNoCC
, fetchurl
, makeWrapper
, nodejs
}:

let
  version = "0.1.8";

  # anydoc's Rust core ships as prebuilt napi modules, one npm package per
  # platform, pulled in as optionalDependencies of @firecrawl/anydoc. Bump
  # these alongside version; regenerate a hash with:
  #   nix store prefetch-file https://registry.npmjs.org/@firecrawl/anydoc-<target>/-/anydoc-<target>-<version>.tgz
  targets = {
    aarch64-darwin = { target = "darwin-arm64"; hash = "sha256-OjQX9wIadbkFgUc9i+dJlCfpdiFPvdbNLq33BEs3xRM="; };
    x86_64-darwin = { target = "darwin-x64"; hash = "sha256-aZWkudBsADZcDWsY6RScRNAXBg2y2joMP/r75hY0IOU="; };
    aarch64-linux = { target = "linux-arm64-gnu"; hash = "sha256-/ZOMAFxPqWX/JC1PJF+fGwmIwDqfo2R9H1JM1HK7f8o="; };
    x86_64-linux = { target = "linux-x64-gnu"; hash = "sha256-hRl2LcdnNfK7VHE4G+m96t4DkxU+bvqqM68nvhXjF/A="; };
  };

  inherit (stdenvNoCC.hostPlatform) system;
  native = targets.${system} or (throw "anydoc: no prebuilt native module for ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "anydoc";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@firecrawl/anydoc/-/anydoc-${version}.tgz";
    hash = "sha256-j5LSrbKX7IzgPnn9dAMOm2Dz5NHXxuBjgsAhxRPPij0=";
  };

  nativeModule = fetchurl {
    url = "https://registry.npmjs.org/@firecrawl/anydoc-${native.target}/-/anydoc-${native.target}-${version}.tgz";
    inherit (native) hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/anydoc
    # cli.js requires ./index.js and ./package.json (for --version) at runtime
    cp cli.js index.js index.d.ts package.json $out/lib/anydoc/
    tar xzf $nativeModule --strip-components=1 -C $out/lib/anydoc \
      package/anydoc.${native.target}.node

    # index.js checks NAPI_RS_NATIVE_LIBRARY_PATH before its platform-detection
    # cascade, so pointing it at the one module we ship skips that entirely.
    makeWrapper ${lib.getExe nodejs} $out/bin/anydoc \
      --add-flags $out/lib/anydoc/cli.js \
      --set NAPI_RS_NATIVE_LIBRARY_PATH $out/lib/anydoc/anydoc.${native.target}.node

    runHook postInstall
  '';

  meta = {
    description = "Convert documents (docx, pdf, pptx, xlsx, epub, csv, …) to GitHub-Flavored Markdown";
    homepage = "https://github.com/firecrawl/anydoc";
    license = lib.licenses.mit;
    mainProgram = "anydoc";
    platforms = builtins.attrNames targets;
  };
}
