{ writeShellApplication, jq }:

writeShellApplication {
  name = "msgvault-token";
  runtimeInputs = [ jq ];
  text = builtins.readFile ./msgvault-token.sh;
}
