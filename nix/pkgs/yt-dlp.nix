{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  deno,
  ffmpeg-headless,
}:

stdenvNoCC.mkDerivation rec {
  pname = "yt-dlp-bin";
  version = "2026.10.21";

  src = fetchurl {
    url = "https://github.com/yt-dlp/yt-dlp/releases/download/${version}/yt-dlp_macos";
    hash = "sha256-em/nHX1oDx+wrBjUlJhz132yhZ6QAXwPRL2Usjvk7kA=";
  };

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  # deno solves YouTube's JS challenges; without it most formats are missing
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/libexec/yt-dlp
    makeWrapper $out/libexec/yt-dlp $out/bin/yt-dlp \
      --prefix PATH : ${
        lib.makeBinPath [
          deno
          ffmpeg-headless
        ]
      }
    runHook postInstall
  '';

  meta = {
    description = "Feature-rich command-line audio/video downloader";
    homepage = "https://github.com/yt-dlp/yt-dlp";
    license = lib.licenses.unlicense;
    mainProgram = "yt-dlp";
    platforms = lib.platforms.darwin;
  };
}
