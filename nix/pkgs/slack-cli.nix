{ rustPlatform
, fetchFromGitHub
, lib
}:

rustPlatform.buildRustPackage rec {
  pname = "slack-cli";
  version = "0.1.1";

  # No git tags upstream; pin the main commit that published cli v0.1.1.
  src = fetchFromGitHub {
    owner = "isaacadams";
    repo = "slack-api-client";
    rev = "b609e5a1b661b94eb0506b23e1afac7e0c313bc6";
    hash = "sha256-eHj6JfzlGRay8RMa44Ju22yS2zUSlfTZcWAGuiEuD1o=";
  };

  cargoHash = "sha256-tbi3rHv/3bfwveWInYw5dJ9xVSCDP2AmggzuYciwOsA=";

  # Workspace: root is the slack-api-client lib, the binary lives in the cli
  # member (package slack-cli, binary `slack`).
  cargoBuildFlags = [ "-p" "slack-cli" ];

  doCheck = false;

  meta = {
    description = "Command-line client for the Slack API";
    homepage = "https://github.com/isaacadams/slack-api-client";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "slack";
  };
}
