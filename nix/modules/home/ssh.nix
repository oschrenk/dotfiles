# ssh client config. No keys live here: authentication goes through the
# 1Password agent, so ~/.ssh holds only config and ssh's own known_hosts.
# Migrated from chezmoi (home/private_dot_ssh/).
{ lib, ... }:
{
  programs.ssh = {
    enable = true;

    # Without this, home-manager prepends a Host * block of its own legacy
    # defaults, which would add ForwardAgent, Compression, AddKeysToAgent and
    # UserKnownHostsFile lines that the hand-written config never had.
    enableDefaultConfig = false;

    includes = [ "config.d/*" ];

    # settings rather than matchBlocks: the latter is deprecated and warns on
    # every rebuild. Keys here are the ssh directive names as written in the
    # config file.
    settings."*" = {
      # Route all key auth through 1Password's SSH agent. Quoted because the
      # path contains spaces, and ssh wants the quotes in the file.
      IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';

      # Don't store hostnames and IPs in known_hosts in cleartext
      HashKnownHosts = true;

      ServerAliveCountMax = 30;
      ServerAliveInterval = 10;

      # Share one channel per host rather than opening a new one each time,
      # which makes repeat connections much quicker.
      ControlMaster = "auto";
      ControlPath = "~/.ssh/sockets/%C";
      ControlPersist = "1m";
    };
  };

  # ControlPath writes into sockets/, and the Include above reads config.d/.
  # ssh creates neither, and chezmoi was carrying a .keep in each to make them
  # exist. 0700 because ~/.ssh should not be group or world readable.
  home.activation.sshDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.ssh/sockets" "$HOME/.ssh/config.d"
    run chmod 700 "$HOME/.ssh" "$HOME/.ssh/sockets" "$HOME/.ssh/config.d"
  '';
}
