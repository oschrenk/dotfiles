_:

{
  # shared configuration across all machines

  # Determinate Nix manages its own daemon — disable nix-darwin's Nix management
  # to avoid conflicts. Some nix.* options will be unavailable as a result.
  nix.enable = false;

  # A sudo rebuild fetches the private flake as root, which has no known_hosts of its own.
  programs.ssh.knownHosts."github.com".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

}
