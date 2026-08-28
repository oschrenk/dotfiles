{ pkgs, lib, nixpkgs-zed, ... }:

{
  # Unfree is denied by default. Allow it per package rather than wholesale, so
  # adding one never quietly permits the next.
  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) [
      # official AgileBits universal .pkg, unpacked rather than rebuilt, so the
      # signature the 1Password desktop app checks for app integration is intact
      "1password-cli"
    ];

  nixpkgs.overlays = [
    (_final: prev: {
      # Pin zed-editor to a rev whose build is already cached, so a rolling
      # nixpkgs bump doesn't trigger a from-source Rust recompile. See the
      # nixpkgs-zed input in flake.nix.
      zed-editor = nixpkgs-zed.legacyPackages.${prev.stdenv.hostPlatform.system}.zed-editor;
      # direnv's test suite hangs on macOS sandboxed builds
      direnv = prev.direnv.overrideAttrs (_old: { doCheck = false; });
      # gitwatch-rs not in nixpkgs; build from source via our own derivation
      # (upstream flake's rust-flake/rust-overlay chain is broken on darwin)
      gitwatch-rs = prev.callPackage ../pkgs/gitwatch-rs.nix { };
      # cottage not in nixpkgs; build from source
      cottage = prev.callPackage ../pkgs/cottage.nix { };
      # tlink not in nixpkgs; use upstream prebuilt darwin binary
      tlink = prev.callPackage ../pkgs/tlink.nix { };
      # firemark not in nixpkgs; build from source
      firemark = prev.callPackage ../pkgs/firemark.nix { };
      # kmp-lsp not in nixpkgs; build from source (was the cargo crate
      # kotlin-lsp, since renamed by upstream to kmp-lsp)
      kmp-lsp = prev.callPackage ../pkgs/kmp-lsp.nix { };
      # msgvault not in nixpkgs; upstream ships prebuilt darwin archives, and
      # its own flake would build Go 1.27 from source
      msgvault = prev.callPackage ../pkgs/msgvault.nix { };
      # tmignore-rs not in nixpkgs; upstream ships prebuilt darwin archives
      tmignore-rs = prev.callPackage ../pkgs/tmignore-rs.nix { };
    })
  ];

  environment.systemPackages = with pkgs; [
    _1password-cli
    aerospace
    blueutil
    coursier # jvm, scala, artifact fetching
    croc # cryptography, secure data transfer
    doggo
    exiftool
    fd # system, fast find alternative
    ffmpeg # a/v, convert audio/video. bundles libx264, libxvid and libmp3lame
    firemark
    gallery-dl
    gawk # system, GNU awk utility
    git-stack
    htop
    httrack # network, copy websites offline
    hurl
    jd-diff-patch # data, diff JSON. provides `jd`
    jq
    jsongrep
    kmp-lsp
    lua-language-server # lua, lsp
    mdq
    minisign
    msgvault
    ngrep
    nmap # network, port scanning
    page
    rclone # system, sync files
    rsync # system, sync files
    shellcheck
    smartmontools
    speedtest-cli
    stylua # lua formatter
    taplo
    tree
    witr
    yq-go # data, process YAML. provides `yq`
    yt-dlp
    zed-editor
  ];
}
