{ private, ... }:
{
  my.personal = {
    username = "oliver";
    name = "Oliver Schrenk";
    email = "oliver.schrenk@gmail.com";
    timezone = "America/Guatemala";
    sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ0G3UHhaDSkbGrbopLIIrp5CRh48opdepjUQQPTJ+r";
  };

  my.work.email = private.identity.workEmail;
}
