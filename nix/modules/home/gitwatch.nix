{ config, lib, pkgs, ... }:

let
  inherit (lib) literalExpression mkOption mapAttrs' nameValuePair types;

  defaultCommitScript = pkgs.writeShellApplication {
    name = "gitwatch-commit-message";
    runtimeInputs = [ pkgs.git ];
    text = ''
      git diff --staged --name-only
    '';
  };
in
{
  options.services.gitwatch = mkOption {
    default = { };
    type = types.attrsOf (types.submodule {
      options = {
        repo_path = mkOption {
          type = types.path;
          example = literalExpression ''"''${config.home.homeDirectory}/notes"'';
          description = "The local repository path to watch.";
        };

        args = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = [ "--debounce-seconds=3" "--remote=origin" ];
          description = "Extra args passed to `gitwatch watch`.";
        };

        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
          example = literalExpression "with pkgs; [ git coreutils ]";
          description = ''
            Extra packages on PATH for the daemon and any commit-message
            script it invokes.
          '';
        };

        environment = mkOption {
          type = types.attrsOf types.str;
          default = { };
          example = literalExpression ''{
            SSH_AUTH_SOCK = "''${config.home.homeDirectory}/.../agent.sock";
          }'';
          description = ''
            Extra environment variables for the launchd agent. Useful for
            things like `SSH_AUTH_SOCK` when pushing to remotes (launchd
            does not inherit the interactive shell's environment).
          '';
        };

        commitMessageScript = mkOption {
          type = types.nullOr (types.either types.path types.str);
          default = lib.getExe' defaultCommitScript "gitwatch-commit-message";
          defaultText = lib.literalMD
            "script emitting `git diff --staged --name-only`";
          description = ''
            Path to an executable that prints the commit message to stdout.
            Set to `null` to use gitwatch-rs's `--commit-message` instead
            (pass via `args`). `--commit-message` and
            `--commit-message-script` are mutually exclusive at the CLI
            level, so don't combine a non-null `commitMessageScript` with a
            `--commit-message` in `args`.
          '';
        };
      };
    });
  };

  config = {
    home.packages = [ pkgs.gitwatch-rs ];

    services.gitwatch.infuse = {
      repo_path = "${config.home.homeDirectory}/.local/share/infuse";
      # --network-timeout-seconds bounds fetch and push, so an SSH agent that
      # never answers ends in a logged error instead of a wedged daemon.
      #
      # --ssh-key is what keeps it from reaching an agent at all. It names a
      # deploy key registered on infuse-data alone, so the daemon authenticates
      # without a person there to unlock anything. Passing it also disables the
      # agent and the interactive prompts, which is why no SSH_AUTH_SOCK is set
      # below. libgit2 has no ssh_config parser, so IdentityFile in ~/.ssh/config
      # would not have worked; the flag is the only way to choose a key here.
      #
      # scripts/bootstrap-infuse.sh writes the key from 1Password on a fresh
      # machine. It stays out of the nix store, which is world-readable.
      args = [
        "--debounce-seconds=3"
        "--network-timeout-seconds=60"
        "--ssh-key=${config.home.homeDirectory}/.ssh/gitwatch_infuse_ed25519"
        "--remote=origin"
        "--pull-before-push"
        "--skip-if-merging"
      ];
      extraPackages = [ pkgs.git ];
    };

    launchd.agents = mapAttrs' (name: cfg:
      let
        scriptArgs =
          lib.optionals (cfg.commitMessageScript != null)
            [ "--commit-message-script" (toString cfg.commitMessageScript) ];
      in
      nameValuePair "gitwatch-${name}" {
        enable = true;
        config = {
          ProgramArguments =
            [ "${pkgs.gitwatch-rs}/bin/gitwatch" "watch" ]
            ++ scriptArgs
            ++ cfg.args
            ++ [ (toString cfg.repo_path) ];
          RunAtLoad = true;
          KeepAlive = {
            SuccessfulExit = false;
          };
          WorkingDirectory = toString cfg.repo_path;
          EnvironmentVariables =
            cfg.environment
            // lib.optionalAttrs (cfg.extraPackages != [ ]) {
              PATH = lib.makeBinPath cfg.extraPackages;
            };
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/gitwatch-${name}.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/gitwatch-${name}.log";
        };
      }
    ) config.services.gitwatch;
  };
}
