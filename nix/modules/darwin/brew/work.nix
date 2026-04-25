{ ... }:

# Homebrew packages for work machines.
# Import this module in the host file for any work machine.
{
  homebrew.brews = [
    "flyway" # sql, database migrations
    "gradle" # kotlin, build tool
    "hadolint" # docker, linter
    "jira-cli" # cli, interact with jira
    "kubelogin" # k8s, openid auth plugin
    "logcli" # o11y, query loki
    "mysql-client@8.0" # mysql, client
    "skopeo" # docker, registry inspect
    "sleek" # sql, formatter
    "snyk-cli" # security, cli, scan for security vulnerabilities
    "sqlfluff" # sql, formatter
    "stern" # k8s, log "aggregator"
    "traefik" # k8s, reverse proxy
    "velero" # k8s, backup/recovery
    "websocat" # cli, websocket
  ];

  homebrew.casks = [
    "dbeaver-community" # sql client
    "docker-desktop" # docker client
    "gcloud-cli" # cloud, google cloud cli including gcloud
    "openvpn-connect" # vpn
  ];
}
