{ ... }:

{
  # shared configuration across all machines

  # Determinate Nix manages its own daemon — disable nix-darwin's Nix management
  # to avoid conflicts. Some nix.* options will be unavailable as a result.
  nix.enable = false;

}
