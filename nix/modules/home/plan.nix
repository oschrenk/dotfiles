# plan — Calendar.app companion CLI, surfaced in the sketchybar Calendar item.
# Package and config both come from the upstream flake's home-manager module.
# Migrated from chezmoi (home/private_dot_config/plan/config.json).
{ plan, lib, pkgs, ... }:
{
  imports = [ plan.homeModules.plan ];

  programs.plan = {
    enable = true;

    iconize = [
      { field = "title.label"; regex = "Movements Yoga"; icon = "🪷"; }
      { field = "title.label"; regex = "Refinement"; icon = "💅"; }
      { field = "title.label"; regex = "1:1"; icon = "🤝"; }
      { field = "title.label"; regex = "Development standup"; icon = "🙋"; }
      { field = "title.label"; regex = "Deploy"; icon = "🚀"; }
    ];

    # The old config pointed at /opt/homebrew/bin/sketchybar, which stopped
    # existing when sketchybar moved to nix, so `plan watch` fired nothing.
    # `Hook.trigger()` hands the path straight to Process without expanding it,
    # so it has to stay absolute.
    hooks = [
      {
        path = lib.getExe pkgs.sketchybar;
        args = [ "--trigger" "calendar_changed" ];
      }
    ];
  };

  # Output templates. The upstream module writes config.json only, and nothing
  # reads these unless a caller passes --template-path, so they are plain files
  # rather than anything the module knows about.
  xdg.configFile."plan/obsidian.md".source = ./plan/obsidian.md;
  xdg.configFile."plan/terminal.md".source = ./plan/terminal.md;
}
