{ ... }:

{
  programs.fzf = {
    enable = true;
    # Fish is managed by chezmoi (programs.fish.enable = false), so HM's
    # interactiveShellInit hook would be discarded. The `fzf --fish | source`
    # hook lives in home/private_dot_config/fish/functions/fish_user_key_bindings.fish
    # instead. See plans/done/fzf-to-hm.md.
    enableFishIntegration = false;
  };
}
