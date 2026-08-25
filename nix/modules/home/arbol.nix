# arbol — clone/sync git repositories across machines from a declarative tree.
# Package and config both come from the upstream flake's home-manager module.
# Migrated from chezmoi (home/private_dot_config/arbol/config.toml).
{ arbol, ... }:
{
  imports = [ arbol.homeModules.arbol ];

  programs.arbol = {
    enable = true;

    accounts.default = {
      default = true;
      root = "~/Projects";

      repos = {
        apps = [
          "git@github.com:oschrenk/ChangeMonitor.git"
          "git@github.com:oschrenk/Contacts.git"
          "git@github.com:oschrenk/kessel.git"
        ];

        forks = [
          "git@github.com:oschrenk/gitwatch-rs.git"
          "git@github.com:oschrenk/mcp-server-macos-use.git"
          "git@github.com:oschrenk/nvim-md-todo-toggle.git"
          "git@github.com:oschrenk/obsidian-electron-window-tweaker.git"
          "git@github.com:oschrenk/obsidian-hider.git"
          "git@github.com:oschrenk/tui-datepicker.git"
        ];

        i25a = [
          "git@github.com:oschrenk/i25a.gt.git"
          "git@github.com:oschrenk/vacar.i25a.gt.git"
        ];

        ops = [
          "git@github.com:oschrenk/bramble.git"
          "git@github.com:oschrenk/feeds.git"
          "git@github.com:oschrenk/homebrew-made.git"
          "git@github.com:oschrenk/homebrew-personal.git"
          "git@github.com:oschrenk/homelab.git"
          "git@github.com:oschrenk/pi-gen.git"
        ];

        oschrenk = [
          "git@github.com:oschrenk/career.git"
          "git@gitlab.com:oschrenk/invoices.git"
          "git@gitlab.com:oschrenk/invoices.tps.git"
        ];

        resources = [
          "git@github.com:oschrenk/dutch-cities-gps.git"
          "git@github.com:oschrenk/icons.git"
          "git@github.com:oschrenk/progress-font.git"
          "git@github.com:oschrenk/sf-mono-nerd-font.git"
          "git@github.com:oschrenk/woodwork.git"
        ];

        sandbox = [
          "git@github.com:oschrenk/cart.kt.git"
          "git@github.com:oschrenk/errors.kt.git"
        ];

        sites = [
          "git@github.com:oschrenk/oschrenk.dev.git"
          "git@github.com:oschrenk/scrumoji.git"
        ];

        timewax = [
          "git@git.timewax.com:nodejs/all-node-apps.git"
          "git@git.timewax.com:python/all-python2-apps.git"
          "git@git.timewax.com:python/all-python3-apps.git"
          "git@git.timewax.com:timewax/backend.git"
          "git@git.timewax.com:timewax/devops.git"
          "git@git.timewax.com:timewax/frontend.git"
          "git@git.timewax.com:timewax/office-365-integration/task-queue.git"
          "git@git.timewax.com:timewax/translations.git"
        ];

        tools = [
          "git@github.com:oschrenk/applaude.git"
          "git@github.com:oschrenk/arbol.git"
          "git@github.com:oschrenk/arto.git"
          "git@github.com:oschrenk/blink-cmp-browser.git"
          "git@github.com:oschrenk/bump.git"
          "git@github.com:oschrenk/bunq.git"
          "git@github.com:oschrenk/cutter.git"
          "git@github.com:oschrenk/display.swift.git"
          "git@github.com:oschrenk/health.git"
          "git@github.com:oschrenk/helenite.swift.git"
          "git@github.com:oschrenk/infuse.git"
          "git@github.com:oschrenk/keyboard.swift.git"
          "git@github.com:oschrenk/legends.git"
          "git@github.com:oschrenk/librelink.git"
          "git@github.com:oschrenk/lzsave.git"
          "git@github.com:oschrenk/meter.git"
          "git@github.com:oschrenk/mission.git"
          "git@github.com:oschrenk/mother.git"
          "git@github.com:oschrenk/nightshift.swift.git"
          "git@github.com:oschrenk/plan.swift.git"
          "git@github.com:oschrenk/pomodoro.git"
          "git@github.com:oschrenk/sessionizer.git"
          "git@github.com:oschrenk/team.git"
          "git@github.com:oschrenk/up.git"
          "git@github.com:oschrenk/usbi.git"
          "git@github.com:oschrenk/wallpaper.swift.git"
        ];

        wip = [
          "git@github.com:oschrenk/pulse.git"
        ];
      };
    };
  };
}
