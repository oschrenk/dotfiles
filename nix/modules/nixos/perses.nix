{
  config,
  pkgs,
  lib,
  ...
}:
let
  username = config.my.personal.username;

  encryptionKeyFile = "/var/lib/opnix/secrets/persesEncryptionKey";
  adminPasswordFile = "/var/lib/opnix/secrets/persesAdminPassword";

  # Provisioning is re-applied at every start, so these resources are the source
  # of truth and the UI is a read path. Deleting the data directory must leave
  # the datasource, project and login recoverable from here alone.
  provisioningDir = "/run/perses/provisioning";

  # One resource per file. Perses provisioning reads only the FIRST document of a
  # multi-document YAML file and silently ignores the rest — no error, no log line.
  # A single file with `---` separators looks correct and provisions one resource.
  resources = {
    "01-project.yaml" = ''
      kind: "Project"
      metadata:
        name: "homelab"
      spec:
        display:
          name: "Homelab"
    '';

    "02-datasource.yaml" = ''
      kind: "GlobalDatasource"
      metadata:
        name: "prometheus"
      spec:
        default: true
        plugin:
          kind: "PrometheusDatasource"
          spec:
            directUrl: "http://127.0.0.1:${toString config.services.prometheus.port}"
    '';

    # Without a binding the account authenticates but sees nothing: reads are
    # rejected as "missing 'read' global permission", and list endpoints return an
    # empty array rather than an error, which reads like provisioning failed.
    "03-global-role.yaml" = ''
      kind: "GlobalRole"
      metadata:
        name: "admin"
      spec:
        permissions:
          - actions: ["*"]
            scopes: ["*"]
    '';

    "04-global-role-binding.yaml" = ''
      kind: "GlobalRoleBinding"
      metadata:
        name: "admin"
      spec:
        role: "admin"
        subjects:
          - kind: "User"
            name: "${username}"
    '';
  };

  resourceDir = pkgs.linkFarm "perses-resources" (
    lib.mapAttrsToList (name: text: {
      inherit name;
      path = pkgs.writeText name text;
    }) resources
  );
in
{
  config = {
    services.perses = {
      enable = true;

      # All interfaces: Traefik on pi-1 proxies this over the tailnet, the same
      # path the kula backends use. base.nix opens no LAN ports and trusts
      # tailscale0, so only the tailnet can reach it.
      listenAddress = "0.0.0.0";

      # Port deliberately left at the module default. sites/lab.oschrenk.gt.nix
      # is evaluated on pi-1, where perses is not enabled, and reads
      # services.perses.port from that same default — overriding it here would
      # silently desync the Traefik backend.

      settings = {
        database.file = {
          folder = "/var/lib/perses/data";
          extension = "yaml";
        };

        security = {
          enable_auth = true;
          # Must be exactly 32 raw characters — perses uses it as an AES-256 key
          # directly and does not hex- or base64-decode it. `openssl rand -hex 16`
          # gives 32 chars; `-hex 32` gives 64 and fails with
          # "encryption_key size must be 32 bytes".
          #
          # _secret is the module's own mechanism: the value is loaded via
          # LoadCredential and substituted into /run/perses/config.yaml at start,
          # so the key never enters the world-readable nix store.
          encryption_key._secret = encryptionKeyFile;
          authentication = {
            providers.enable_native = true;
            # Anyone who can reach the tailnet could otherwise create an account.
            disable_sign_up = true;
          };
        };

        provisioning = {
          # Datasources are validated against plugin schemas, and those schemas are
          # still loading when provisioning first runs — the GlobalDatasource fails
          # with "datasource schemas are not loaded" and, without a retry, never
          # lands. Resources without a schema dependency (Project, roles) are
          # unaffected, which makes the failure look selective.
          #
          # Re-applying also keeps these resources authoritative: an edit made in the
          # UI is reverted on the next pass, so the repo stays the source of truth.
          interval = "1m";
          folders = [ provisioningDir ];
        };
      };
    };

    # The admin password reaches perses as plaintext inside a provisioned User
    # resource — perses hashes and salts it on ingest, but the file on disk holds
    # it in the clear. That rules out the nix store, so the resource is rendered
    # at start into RuntimeDirectory, which UMask=0027 keeps at 0640 owned by the
    # perses dynamic user.
    systemd.services.perses = {
      # The upstream module orders only after networking.target, so perses raced
      # opnix and hit its start limit before either secret existed. Both are loaded
      # as credentials, which systemd resolves before ExecStartPre — a missing file
      # is 243/CREDENTIALS, not a retryable error.
      after = [ "opnix-secrets.service" ];
      requires = [ "opnix-secrets.service" ];

      serviceConfig.LoadCredential = [ "persesAdminPassword:${adminPasswordFile}" ];

      preStart = lib.mkAfter ''
        mkdir -p ${provisioningDir}
        # -L because linkFarm produces symlinks into the store.
        cp -L ${resourceDir}/*.yaml ${provisioningDir}/

        cat > ${provisioningDir}/user.yaml <<EOF
        kind: "User"
        metadata:
          name: "${username}"
        spec:
          nativeProvider:
            password: "$(cat "$CREDENTIALS_DIRECTORY/persesAdminPassword")"
        EOF
      '';
    };
  };
}
