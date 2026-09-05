# sessionizer — fuzzy finder for creating and switching between tmux sessions.
# Package and config both come from the upstream flake's home-manager module.
{ sessionizer, ... }:
let
  entry = name: path: { inherit name path; };
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

    startup = {
      name = "ops/dotfiles";
      path = "$HOME/Projects/ops/dotfiles";
    };

    # reaches the manual entries and the walked $HOME/Projects alike
    default.layout = "two-columns-claude";

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
        (entry "interests/guatemala" "$HOME/Obsidian/memex/30 Resources/Places/Guatemala")
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
              # Joined with spaces and typed into the pane's shell, not exec'd
              # as argv, so shell operators work here. The fallback covers a
              # directory with no prior conversation.
              shell_command = [ "claude --continue || claude" ];
              focus = true;
            }
          ];
        }
      ];
    };
  };
}
