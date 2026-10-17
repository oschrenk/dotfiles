{ config, lib, ... }:

# NSConvolutionOverride1 — undocumented NSGlobalDomain key that overrides the
# macOS Tahoe "Liquid Glass" window-corner convolution (the corner blur/round
# pass). Community-discovered; Apple does not document it.
#
# The value is a bit-pattern selector, not a magnitude: 1.4e-45 is the smallest
# positive float32, whose 32-bit pattern is exactly 0x00000001, so this selects
# variant "1" through a float-typed key. It cannot go through
# CustomUserPreferences: nix stringifies 1.4e-45 to "0.000000" (bit pattern
# 0x0), which would select the wrong variant. So we run the literal defaults
# command, which preserves the exact float.
#
# Must hook into postActivation (a hardcoded nix-darwin activation script):
# custom script names are defined but never executed. mkAfter keeps this
# composable with other postActivation users. Written as the user via sudo -u
# because -g targets the user's global domain, not root's.
{
  system.activationScripts.postActivation.text = lib.mkAfter ''
    sudo -u ${config.my.personal.username} defaults write -g NSConvolutionOverride1 -float 1.4e-45
  '';
}
