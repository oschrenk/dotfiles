# mission — Obsidian journal tasks and macOS Focus, surfaced in sketchybar.
# Package and config both come from the upstream flake's home-manager module.
# Migrated from chezmoi (home/private_dot_config/mission/config.toml).
{ mission, ... }:
{
  imports = [ mission.homeModules.mission ];

  programs.mission = {
    enable = true;

    vault = {
      name = "memex";
      path = "$HOME/Obsidian/memex";
    };

    journals = {
      default.path = "$HOME/Obsidian/memex/40 Journals/Personal";
      work.path = "$HOME/Obsidian/memex/40 Journals/Work";
    };
  };
}
