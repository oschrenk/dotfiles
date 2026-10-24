{ lib, private, ... }:
{
  options.my.personal = {
    username = lib.mkOption { type = lib.types.str; };
    name = lib.mkOption { type = lib.types.str; };
    email = lib.mkOption { type = lib.types.str; };
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
    };
    sshKey = lib.mkOption { type = lib.types.str; };
  };

  options.my.work = {
    email = lib.mkOption { type = lib.types.str; };
  };

  config = {
    my.personal = {
      username = "oliver";
      name = "Oliver Schrenk";
      email = "oliver.schrenk@gmail.com";
      timezone = "America/Guatemala";
      sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ0G3UHhaDSkbGrbopLIIrp5CRh48opdepjUQQPTJ+r";
    };

    my.work.email = private.identity.workEmail;
  };
}
