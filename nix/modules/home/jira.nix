# jira-cli helpers. Config is rendered by opnix (modules/darwin/secrets.nix);
# the token + JIRA_CONFIG_FILE are set per-project in .envrc.local — jira-cli-go
# and the 1Password service account come from the project's devshell, not here.
{ ... }:
{
  # Helper: space-joined keys of your top-3 in-progress tickets.
  xdg.configFile."jira/mine.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      jira issue list --plain --no-headers -a$(jira me) -s"In Progress" 2>/dev/null | head -3 | awk '{print $2}' | awk -v d=" " '{s=(NR==1?s:s d)$0}END{print s}'
    '';
  };

  xdg.configFile."jira/README.md".text = ''
    # jira-cli (nix-managed)

    - Config `~/.config/jira/config.yml`: rendered from a 1Password field by opnix.
    - Token: set per-project in .envrc.local via `op read` (the project devshell
      provides jira-cli-go and the 1Password service account).
  '';
}
