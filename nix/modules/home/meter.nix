# meter — Claude Max plan usage limits on the command line.
# Package and config both come from the upstream flake's home-manager module.
# Migrated from chezmoi (home/private_dot_config/meter/config.toml) and from
# the oschrenk/made/meter brew formula.
{ meter, ... }:
{
  imports = [ meter.homeModules.meter ];

  programs.meter = {
    enable = true;

    # The two values below are keychain service names, not credentials. The
    # OAuth tokens stay in the macOS keychain and `security find-generic-password`
    # is what reads them.
    accounts = {
      personal = {
        default = true;
        path = "$HOME/.config/claude/personal";
        keychainService = "Claude Code-credentials-804fbf04";
      };
      work = {
        path = "$HOME/.config/claude/work";
        keychainService = "Claude Code-credentials-b1002bd9";
      };
    };
  };
}
