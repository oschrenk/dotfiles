{ ... }:

{
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";

    secrets.atuinKey = {
      reference = "op://pfu2umtvmdm7k7aefhzrc4pkey/he5hrszuaoz2rwn6bc22obb3ui/password";
      path = "/Users/oliver/.local/share/atuin/key";
      owner = "oliver";
      group = "staff";
      mode = "0400";
    };

    secrets.cottageIdentity = {
      reference = "op://pfu2umtvmdm7k7aefhzrc4pkey/flw2qcdysxrzsbus7kkdgupncy/password";
      path = "/Users/oliver/.config/cottage/identity";
      owner = "oliver";
      group = "staff";
      mode = "0400";
    };

    # Full jira config — kept out of this public repo, stored in the Bootstrap
    # vault (the one the opnix service account can read). jira reads it via
    # JIRA_CONFIG_FILE set in the wrapper.
    secrets.jiraConfig = {
      reference = "op://pfu2umtvmdm7k7aefhzrc4pkey/sixufe2idosinhgbqbzuvvukyi/config";
      path = "/Users/oliver/.config/jira/config.yml";
      owner = "oliver";
      group = "staff";
      mode = "0400";
    };
  };
}
