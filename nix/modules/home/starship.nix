{ ... }:

{
  programs.starship = {
    enable = true;

    settings = {
      # insert a blank line between shell prompts
      add_newline = false;

      format = "$kubernetes$directory$git_branch$git_commit$git_state$git_metrics$git_status$helm$custom$sudo$cmd_duration\n$jobs$time$status$character";

      # set gruvbox as custom color palette
      palette = "gruvbox";

      directory.style = "bold green";

      kubernetes = {
        disabled = false;
        detect_files = [ ".kube" ];
        format = "[$symbol $context $namespace]($style)";
        symbol = "🛶";
        style = "aqua";
      };

      git_branch = {
        symbol = "🌿";
        style = "bold yellow";
      };

      git_metrics = {
        disabled = false;
        added_style = "green";
        deleted_style = "red";
        format = "([+$added]($added_style))([-$deleted]($deleted_style) )";
        ignore_submodules = true;
      };

      git_status = {
        # not including modified, preferring git_metrics
        format = "$ahead$behind$diverged$conflicted$deleted$staged$renamed$untracked$stashed";
        conflicted = "[≠\$count ](bold red)";
        ahead = "[⇡\$count ](bold purple)";
        behind = "[⇣\$count ](bold purple)";
        diverged = "[⇕\$count ](bold purple)";
        untracked = "[+\$count ](bold orange)";
        modified = "[~\$count ](bold yellow)";
        staged = "[++\$count ](bold green)";
        renamed = "[»\$count ](bold white)";
        deleted = "[✘\$count ](bold red)";
        stashed = "[x\$count ](bold purple)";
      };

      cmd_duration.style = "bold yellow";

      custom.claude = {
        description = "Shows an AI emoji if the current directory has AI context files.";
        detect_files = [ "CLAUDE.md" ];
        format = "[with \$symbol ](\$style)";
        style = "white";
        symbol = "🤖";
      };

      # define custom colors (gruvbox palette)
      palettes.gruvbox = {
        aqua = "#8ec07c";
        blue = "#83a598";
        gray = "#928374";
        green = "#b8bb26";
        orange = "#fe8019";
        purple = "#d3869b";
        red = "#fb4934";
        white = "#ebdbb2"; # fg
        yellow = "#fabd2f";
        fg = "#ebdbb2";
        fg0 = "#fbf1c7";
        fg1 = "#ebdbb2";
        fg2 = "#bdae93";
      };
    };
  };
}
