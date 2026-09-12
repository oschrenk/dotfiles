{ config, lib, ... }:

let
  secrets = (import ../../secrets.nix).read ../../../secretspec.toml;

  cfg = config.services.onepassword-secrets;

  # opnix only sets owner/group/mode on the secret file, never on its parent.
  # Its launchd daemon runs as root and MkdirAll's that parent, so whether the
  # directory ends up root- or user-owned is a race against home-manager's
  # linkGeneration — and the winner sticks, which makes it look machine-specific.
  # extraActivation runs before both the launchd and postActivation (home-manager)
  # phases, so creating the directories here decides it up front.
  secretDirs = lib.unique (
    lib.mapAttrsToList (_: secret: {
      dir = builtins.dirOf secret.path;
      inherit (secret) owner group;
    }) (lib.filterAttrs (_: secret: lib.hasPrefix "/Users/" secret.path) cfg.secrets)
  );
in

{
  system.activationScripts.extraActivation.text = lib.concatMapStringsSep "\n" (d: ''
    mkdir -p '${d.dir}'
    chown ${d.owner}:${d.group} '${d.dir}'
  '') secretDirs;

  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    secrets.atuinKey = {
      reference = secrets.ref "ATUIN_SYNC_KEY";
      path = "/Users/oliver/.local/share/atuin/key";
      owner = "oliver";
      group = "staff";
      mode = "0400";
    };

    secrets.cottageIdentity = {
      reference = secrets.ref "COTTAGE_IDENTITY";
      path = "/Users/oliver/.config/cottage/identity";
      owner = "oliver";
      group = "staff";
      mode = "0400";
    };

    # Full jira config — kept out of this public repo, stored in the Bootstrap
    # vault (the one the opnix service account can read). jira reads it via
    # JIRA_CONFIG_FILE set in the wrapper.
    secrets.jiraConfig = {
      reference = secrets.ref "JIRA_CONFIG";
      path = "/Users/oliver/.config/jira/config.yml";
      owner = "oliver";
      group = "staff";
      mode = "0400";
    };
  };
}
