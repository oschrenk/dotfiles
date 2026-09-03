# unpoller pinned ahead of nixpkgs for its UNAS input plugin.
#
# nixpkgs is on 3.5.0 (master) / 3.4.1 (pinned); UNAS support landed in v4.0.0 on
# 2026-08-19. A UNAS Pro is a standalone UniFi OS console with no Network application,
# so inputunifi cannot poll it — the separate `[unas]` input is the only route, and it
# is what removes any need for a custom exporter.
#
# Drop this override once nixpkgs carries 4.x.
{ unpoller, fetchFromGitHub }:
unpoller.overrideAttrs (old: rec {
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "unpoller";
    repo = "unpoller";
    rev = "v${version}";
    hash = "sha256-dyLHje8Y0tIDKwCm4On8/UeRXhBeDeyVMql/gjjHQtk=";
  };

  vendorHash = "sha256-QD2mEakQMlhIwPZ5iH5BFWnH/W3Lx8PGktigYbp4zyU=";

  ldflags = [
    "-w"
    "-s"
    "-X golift.io/version.Version=${version}"
  ];
})
