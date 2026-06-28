{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    shellAliases = {
      # ls → lsd
      ls = "lsd";
      ll = "lsd -l";
      la = "lsd -la";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      d = "cd $HOME/Downloads";
      p = "cd $HOME/Projects";

      # Applications
      b = "brew";
      c = "chezmoi";
      r = "rg";
      t = "task";
      o = "/Applications/Obsidian.app/Contents/MacOS/Obsidian";
      obsidian = "/Applications/Obsidian.app/Contents/MacOS/Obsidian";
      ios = "open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app";

      # git
      "," = "cd (git rev-parse --show-toplevel)";

      # chezmoi
      che = "cd (chezmoi source-path)/..";

      # Make user executable
      cux = "chmod u+x";

      # Sound (requires `brew install sox`)
      noise = "play -q -c 2 --null synth brownnoise band -n 2500 4000 tremolo 20 .1 reverb 50";

      # Fun
      meow = "cat";
    };

    shellAbbrs = {
      # Navigation
      "-" = "cd -";
    };

    plugins = [
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      { name = "nvm";      src = pkgs.fishPlugins.nvm.src; }
    ];

    loginShellInit = ''
      # This block runs on login shells only (responsible for setting up initial environment).
      #
      # set
      # -g or --global
      #        Sets a globally-scoped variable.  Global variables are available to all
      #        functions running in the same shell.  They can be modified or erased.
      # --export or -x
      #        Causes the specified shell variable to be exported to child processes
      #        (making it an "environment variable").

      #############################
      # NIX
      #############################

      # nix-darwin with useUserPackages installs HM packages here
      fish_add_path /etc/profiles/per-user/$USER/bin

      #############################
      # WELL KNOWN
      #############################

      # editor
      set -x EDITOR nvim

      # Set locale
      set -gx LC_ALL en_US.UTF-8
      set -gx LANG en_US.UTF-8

      #############################
      # XDG
      #############################
      set -gx XDG_CACHE_HOME $HOME/.cache
      set -gx XDG_CONFIG_HOME $HOME/.config
      set -gx XDG_DATA_HOME $HOME/.local/share

      # force some apps to respect XDG
      set -gx INPUTRC "$XDG_CONFIG_HOME"/readline/inputrc
      set -gx WGETRC "$XDG_CONFIG_HOME"/wgetrc
      # Mirrors what programs.ripgrep sets via home.sessionVariables. Fish doesn't
      # source hm-session-vars.sh, so we declare it here too. Same path, no drift.
      set -gx RIPGREP_CONFIG_PATH $XDG_CONFIG_HOME/ripgrep/ripgreprc
      set -gx K9S_CONFIG_DIR $XDG_CONFIG_HOME/k9s

      set -gx MSGVAULT_HOME $XDG_CONFIG_HOME/msgvault
      set -gx PI_CODING_AGENT_DIR $XDG_CONFIG_HOME/pi

      #############################
      # PATH
      #############################
      # put homebrew bin before system bin
      fish_add_path --prepend /opt/homebrew/sbin
      fish_add_path --prepend /opt/homebrew/bin

      # put local bin before
      fish_add_path --prepend $HOME/.local/bin

      # Ruby
      fish_add_path --prepend $HOME/.rbenv/shims

      # JVM
      set -x JAVA_HOME (/usr/libexec/java_home -v 21)
      set -x SCALA_HOME /usr/local/opt/scala/

      # Android
      set -x ANDROID_HOME $HOME/Library/Android/sdk
      fish_add_path --append $ANDROID_HOME/emulator
      fish_add_path --append $ANDROID_HOME/tools
      fish_add_path --append $ANDROID_HOME/tools/bin
      fish_add_path --append $ANDROID_HOME/platform-tools

      # Python
      fish_add_path --prepend /opt/homebrew/opt/python@3.12/libexec/bin

      # kubectl krew
      fish_add_path --prepend $HOME/.krew/bin

      # swift
      fish_add_path /opt/homebrew/opt/swift/bin
      set -x SWIFTLY_HOME_DIR "$XDG_DATA_HOME/swiftly"
      set -x SWIFTLY_BIN_DIR "$SWIFTLY_HOME_DIR/bin"
      fish_add_path $SWIFTLY_BIN_DIR

      # whisper cli via ~/.config/fish/functions/transcribe
      set -x WHISPER_MODEL "$XDG_CACHE_HOME/huggingface/hub/models--distil-whisper--distil-small.en/snapshots/5ced4c93e41c640e72b423d596cc7dc0de3f8419/ggml-distil-small.en.bin"

      # Claude
      set -gx CLAUDE_CONFIG_DIR $XDG_CONFIG_HOME/claude/personal
      # disable non-essential traffic individually — avoid the bundle var
      # CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC, which also disables telemetry
      # and silently strips the Monitor tool
      set -gx DISABLE_AUTOUPDATER 1
      set -gx DISABLE_FEEDBACK_COMMAND 1
      set -gx DISABLE_ERROR_REPORTING 1

      # Lightpanda
      set -gx LIGHTPANDA_DISABLE_TELEMETRY true

      #############################
      # homebrew
      #############################
      # disable analytics
      set -gx HOMEBREW_NO_ANALYTICS 1
      # don't print hints about env variables
      set -gx HOMEBREW_NO_ENV_HINTS 1
      # don't show added formulae/casks after update
      set -gx HOMEBREW_NO_UPDATE_REPORT_NEW 1

      #############################
      # fzf
      #############################
      # control colors/styling
      set -gx FZF_DEFAULT_OPTS '--color=bw,prompt:11,fg:,bg+:,fg+: --height 40% --reverse --prompt="󰍉 " --pointer="󰘍" --border=none --no-separator --no-scrollbar --info=hidden'

      # control how fzf is executed when doing :Files in vim
      # relies on `brew install ripgrep`
      # --files: List files that would be searched but do not search
      # --no-ignore: Do not respect .gitignore, etc...
      # --hidden: Search hidden files and folders
      # --follow: Follow symlinks
      # --glob: Additional conditions for search (in this case ignore everything in the .git/ folder)
      set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow --glob "!{.git,node_modules,target}/*"'

      # relies on `brew install fd`
      set -gx FZF_CTRL_T_COMMAND 'fd --type f --type d --hidden --follow --exclude .git'

      #############################
      # ssh
      #############################
      # use 1password for ssh
      set -x SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

      #############################
      # k8s
      #############################
      # automatically offer all $HOME/.kube/config.d/*.yml as K8s configs
      if test -d $HOME/.kube/config.d
        set -x KUBECONFIG (find $HOME/.kube/config.d -name "*.yml" -o -name '*.yaml' | sort | xargs echo | sed 's/ /:/g')
      end

      #############################
      # 1password plugins
      #############################
      if test -f ~/.config/op/plugins.sh
          source ~/.config/op/plugins.sh
      end
    '';

    interactiveShellInit = ''
      # This block runs on interactive shells (connected to a keyboard).

      set fish_greeting

      #############################
      # theme (from fish 4.3 migration)
      #############################
      set --global fish_color_autosuggestion 555 brblack
      set --global fish_color_cancel -r
      set --global fish_color_command blue
      set --global fish_color_comment red
      set --global fish_color_cwd green
      set --global fish_color_cwd_root red
      set --global fish_color_end green
      set --global fish_color_error brred
      set --global fish_color_escape brcyan
      set --global fish_color_history_current --bold
      set --global fish_color_host normal
      set --global fish_color_host_remote yellow
      set --global fish_color_normal normal
      set --global fish_color_operator brcyan
      set --global fish_color_param cyan
      set --global fish_color_quote yellow
      set --global fish_color_redirection cyan --bold
      set --global fish_color_search_match white --background=brblack
      set --global fish_color_selection white --bold --background=brblack
      set --global fish_color_status red
      set --global fish_color_user brgreen
      set --global fish_color_valid_path --underline
      set --global fish_pager_color_completion normal
      set --global fish_pager_color_description B3A06D yellow -i
      set --global fish_pager_color_prefix normal --bold --underline
      set --global fish_pager_color_progress brwhite --background=cyan
      set --global fish_pager_color_selected_background -r

      #############################
      # Google Cloud SDK
      #############################
      if test -f '/opt/homebrew/share/google-cloud-sdk/path.fish.inc'
          source '/opt/homebrew/share/google-cloud-sdk/path.fish.inc'
      end
    '';
  };

  xdg.configFile = {
    "fish/functions" = {
      source = ./fish/functions;
      recursive = true;
    };
    "fish/completions" = {
      source = ./fish/completions;
      recursive = true;
    };
  };
}
