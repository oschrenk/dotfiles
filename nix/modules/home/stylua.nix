{ ... }:
{
  # Baseline, written to ~/.config/stylua/stylua.toml.
  #
  # stylua stops at the first config it finds and does not merge, so a project's
  # own .stylua.toml replaces this file wholesale rather than extending it. That
  # is why config/sketchybar/.stylua.toml restates these three values alongside
  # its [sort_requires] section: dropping them would silently fall back to
  # stylua's own defaults, which are 120 columns of tabs.
  #
  # The search runs upward from the file being formatted, not from the working
  # directory, and reaches this file only because the module wraps the binary
  # with --search-parent-directories. conform.nvim passes that flag itself, so
  # the wrapper is what makes a bare `stylua .` behave like nvim does.
  programs.stylua = {
    enable = true;
    settings = {
      column_width = 120;
      indent_type = "Spaces";
      indent_width = 2;
    };
  };
}
