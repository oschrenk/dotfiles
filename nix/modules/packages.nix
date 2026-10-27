{
  pkgs,
  lib,
  claude-code,
  codex-cli,
  oschrenk-pkgs,
  ...
}:

let
  lint = with pkgs; [
    nixfmt # nix, official formatter
    shellcheck # sh, linter
    taplo # toml, formatter and lsp
    yamlfmt # yaml, formatter
  ];
in
{
  # Unfree is denied by default. Allow it per package rather than wholesale, so
  # adding one never quietly permits the next.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      # official AgileBits universal .pkg, unpacked rather than rebuilt, so the
      # signature the 1Password desktop app checks for app integration is intact
      "1password-cli"
    ];

  nixpkgs.overlays = [
    (_final: prev: {
      inherit (oschrenk-pkgs.packages.${prev.stdenv.hostPlatform.system})
        gitwatch-rs
        tlink
        findbar
        go-task
        despacer
        ;
      # cottage not in nixpkgs; upstream ships a prebuilt darwin binary
      cottage = prev.callPackage ../pkgs/cottage.nix { };
      # firemark not in nixpkgs; upstream ships a prebuilt darwin binary
      firemark = prev.callPackage ../pkgs/firemark.nix { };
      # kmp-lsp not in nixpkgs; upstream ships a prebuilt darwin binary (was the
      # cargo crate kotlin-lsp, since renamed by upstream to kmp-lsp)
      kmp-lsp = prev.callPackage ../pkgs/kmp-lsp.nix { };
      # msgvault not in nixpkgs; upstream ships prebuilt darwin archives, and
      # its own flake would build Go 1.27 from source
      msgvault = prev.callPackage ../pkgs/msgvault.nix { };
      msgvault-token = prev.callPackage ../pkgs/msgvault-token.nix { };
      # tmignore-rs not in nixpkgs; upstream ships prebuilt darwin archives
      tmignore-rs = prev.callPackage ../pkgs/tmignore-rs.nix { };
      # ekctl not in nixpkgs; upstream ships a prebuilt universal darwin binary
      ekctl = prev.callPackage ../pkgs/ekctl.nix { };
      # nixpkgs atuin lags and can compile locally; upstream ships a darwin binary
      atuin = prev.callPackage ../pkgs/atuin.nix { };
      # AeroSpace Alpha fork; ships pending upstream fixes before upstream merges them
      aerospace = prev.callPackage ../pkgs/aerospace.nix { };
      # nixpkgs yt-dlp lags YouTube fixes; upstream ships a darwin binary. A new
      # name, because gallery-dl uses the nixpkgs yt-dlp as a Python library.
      yt-dlp-bin = prev.callPackage ../pkgs/yt-dlp.nix { };
    })
  ];

  environment.systemPackages =
    lint
    ++ (with pkgs; [
      _1password-cli
      aerospace
      blueutil
      coursier # jvm, scala, artifact fetching
      croc # cryptography, secure data transfer
      despacer # rejoins terminal copies that Claude Code wrapped
      doggo
      ekctl # calendar and reminders via EventKit, JSON output
      exiftool
      fd # system, fast find alternative
      ffmpeg # a/v, convert audio/video. bundles libx264, libxvid and libmp3lame
      firemark
      gallery-dl
      gawk # system, GNU awk utility
      git-stack
      go-task
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
      msgvault-token
      ngrep
      nmap # network, port scanning
      page
      rclone # system, sync files
      rsync # system, sync files
      smartmontools
      speedtest-cli
      tree
      witr
      yq-go # data, process YAML. provides `yq`
      yt-dlp-bin
    ])
    ++ [
      claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
      codex-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
