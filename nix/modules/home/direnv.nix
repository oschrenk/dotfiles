{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.hide_env_diff = true;
    # Fish is managed by chezmoi (programs.fish.enable = false), so HM's
    # fish hook would land in an unwritten config file. The hook lives in
    # home/private_dot_config/fish/config.fish instead.
    enableFishIntegration = false;
  };
}
