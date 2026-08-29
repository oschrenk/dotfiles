# sessionizer — fuzzy finder for creating and switching between tmux sessions.
# Package and config both come from the upstream flake's home-manager module.
# Migrated from chezmoi (home/private_dot_config/sessionizer/).
{ sessionizer, ... }:
let
  # every manual entry opens the same two-pane claude layout
  entry = name: path: {
    inherit name path;
    layout = "two-columns-claude";
  };
in
{
  imports = [ sessionizer.homeModules.sessionizer ];

  programs.sessionizer = {
    enable = true;

    base = {
      ignore = [
        ".build"
        "node_modules"
        "private"
      ];
      rooterPatterns = [
        "build.sbt"
        ".git"
        "README.md"
      ];
    };

    default = {
      name = "config";
      path = "$HOME/.config";
    };

    search = {
      directories = [ "$HOME/Projects" ];
      entries = [
        (entry "config/arbol" "$HOME/.config/arbol")
        (entry "config/claude" "$HOME/.config/claude")
        (entry "config/nvim" "$HOME/.config/nvim")
        (entry "config/sessionizer" "$HOME/.config/sessionizer")
        (entry "config/sketchybar" "$HOME/.config/sketchybar")
        (entry "config/tmux" "$HOME/.config/tmux")
        (entry "claude/personal" "$HOME/.config/claude/personal")
        (entry "claude/work" "$HOME/.config/claude/work")
        (entry "interests/5parsecs" "$HOME/Obsidian/memex/20 Areas/5 Parsecs")
        (entry "interests/books" "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Calibre")
        (entry "interests/coffee" "$HOME/Obsidian/memex/20 Areas/Coffee")
        (entry "interests/homelab" "$HOME/Obsidian/memex/20 Areas/Homelab")
        (entry "interests/miniatures" "$HOME/Obsidian/memex/20 Areas/Miniatures")
        (entry "interests/people" "$HOME/Obsidian/memex/80 People")
        (entry "interests/spanish" "$HOME/Obsidian/memex/20 Areas/Spanish")
        (entry "interests/woodworking" "$HOME/Obsidian/memex/20 Areas/Woodworking")
        (entry "self/memex" "$HOME/Obsidian/memex")
        (entry "self/finances" "$HOME/Obsidian/memex/20 Areas/Finances")
        (entry "self/health" "$HOME/Obsidian/memex/20 Areas/Physical Health")
        (entry "self/plan" "$HOME/Obsidian/memex/20 Areas/Plan")
      ];
    };

    layouts = {
      two-columns.windows = [
        {
          layout = "even-horizontal";
          panes = [ { focus = true; } { focus = false; } ];
        }
      ];
      two-columns-claude.windows = [
        {
          layout = "even-horizontal";
          panes = [
            { focus = false; }
            {
              shell_command = [ "claude" ];
              focus = true;
            }
          ];
        }
      ];
    };
  };
}
