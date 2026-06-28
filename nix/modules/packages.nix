{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (_final: prev: {
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
      # slack-cli (isaacadams) not in nixpkgs; build from source
      # (nixpkgs `slack-cli` is a different tool); binary is `slack`
      slack-cli = prev.callPackage ../pkgs/slack-cli.nix { };
    })
  ];

  environment.systemPackages = with pkgs; [
    aerospace
    firemark
    git-stack
    slack-cli
    taplo
    zed-editor
  ];
}
