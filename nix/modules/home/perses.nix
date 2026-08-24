{ pkgs, ... }:
{
  # The perses package ships both the server and percli. Only percli is wanted
  # here — it builds the dashboards in nix/perses/ from CUE.
  #
  # cue is a hard dependency of `percli dac`: without it, setup and build fail
  # with "unable to use the required cue binary". Dashboard dependencies resolve
  # from the CUE module registry at build time rather than being vendored, so a
  # build needs network access and its output is committed.
  home.packages = [
    pkgs.perses
    pkgs.cue
  ];
}
