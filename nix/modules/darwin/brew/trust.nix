{ config, lib, pkgs, ... }:

# Render ~/.config/homebrew/trust.json from the declared brew taps before
# brew bundle runs.
#
# Why not home-manager / xdg.configFile: nix-darwin activation runs brew
# bundle (line ~1232 of the generated activate script) BEFORE home-manager's
# user activation (line ~1256). xdg.configFile lands too late.
#
# Pair: settings.nix sets XDG_CONFIG_HOME in homebrew.onActivation.extraEnv
# so brew bundle reads this file at the canonical XDG path.
let
  user = config.my.personal.username;
  # brew's trust check matches against `Tap#reference`. For default (HTTPS)
  # remotes that's the `user/repo` name; for custom remotes (SSH, forks, etc.)
  # it's the URL. Use clone_target when set in settings.nix so the trust
  # entry matches the actual remote brew records.
  tapReference = t: if t.clone_target != null then t.clone_target else t.name;
  taps = builtins.filter (r: !(lib.hasPrefix "homebrew/" r)) (
    map tapReference config.homebrew.taps
  );
  trustFile = pkgs.writeText "trust.json" (builtins.toJSON { trustedtaps = taps; });
in
{
  system.activationScripts.preActivation.text = lib.mkAfter ''
    install -d -m 755 -o ${user} -g staff /Users/${user}/.config/homebrew
    install -m 644 -o ${user} -g staff ${trustFile} /Users/${user}/.config/homebrew/trust.json
  '';
}
