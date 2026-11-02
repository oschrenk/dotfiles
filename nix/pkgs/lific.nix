{ writeShellApplication }:

# headersHelper for the lific MCP server. Prints the auth header from the file
# opnix renders, so opening a Claude session never triggers a 1Password dialog.
writeShellApplication {
  name = "lific-mcp-headers";
  text = ''
    printf '{"Authorization":"Bearer %s"}' "$(<"$HOME/.config/lific/token")"
  '';
}
