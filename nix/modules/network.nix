{ config, ... }:

{
  # nix-darwin has no `networking.hosts` (NixOS-only). Manage /etc/hosts via
  # environment.etc. This REPLACES the file, so the macOS defaults must be
  # included here.
  environment.etc."hosts".text = ''
    ##
    # Host Database
    #
    # localhost is used to configure the loopback interface
    # when the system is booting.  Do not change this entry.
    ##
    127.0.0.1	localhost
    255.255.255.255	broadcasthost
    ::1             localhost

    # Pin hostnames to static IPs to bypass unreliable Avahi DNS on UNAS.
    ${config.my.nas.ip}	${config.my.nas.hostName}
  '';
}
