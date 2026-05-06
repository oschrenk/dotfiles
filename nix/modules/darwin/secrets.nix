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
      mode = "0600";
    };
  };
}
