/**
    Build 1Password `op://vault/item[/section]/field` reference strings from a secretspec manifest.

    The library supports 1Password schemas like
    - `onepassword://[account@]<vault>` or
    - `onepassword+token://…`.
    and outouts reference schemas in the form of
    - `op://<vault>/<item>[/<section>]/<field>`.

  Currently not supported:
   - `refs` table,
   - provider-alias `ref` templates
   - profile inheritance from `default`.
   - scopes

    # Usage

    ```nix
    let catalogue = (import ./secrets.nix).read ./secretspec.toml;
    in catalogue.ref "NTFY_HOMELAB_BACKUPS_URL"
    => "op://Homelab/Ntfy/homelab-backups"
    ```
*/
let
  # Schemes of a 1Password provider URI
  providerSchemes = [
    "onepassword://"
    "onepassword+token://"
  ];

  # Scheme of a secret reference
  refScheme = "op://";

  # The default profile
  profileName = "default";

  /**
    The remainder of a string after a prefix, or null when it does not match.

    # Type

    ```
    stripPrefix :: String -> String -> Null | String
    ```
  */
  stripPrefix =
    prefix: s:
    let
      n = builtins.stringLength prefix;
    in
    if builtins.substring 0 n s == prefix then
      builtins.substring n (builtins.stringLength s) s
    else
      null;

  /**
    First non-null result of applying f to each element, or null.

    # Type

    ```
    firstJust :: (a -> Null | b) -> [a] -> Null | b
    ```
  */
  firstJust =
    f: xs:
    let
      hits = builtins.filter (x: x != null) (map f xs);
    in
    if hits == [ ] then null else builtins.head hits;

  /**
    Drop the optional account in
    `onepassword://account@Vault`. A vault name cannot contain "@", because
    secretspec never percent-encodes it.

    # Type

    ```
    dropUserinfo :: String -> String
    ```
  */
  dropUserinfo =
    s:
    let
      parts = builtins.split "@" s;
      strings = builtins.filter builtins.isString parts;
    in
    builtins.elemAt strings (builtins.length strings - 1);

  /**
    Drop attributes whose value is null.

    # Type

    ```
    filterNull :: AttrSet -> AttrSet
    ```
  */
  filterNull =
    attrs:
    builtins.removeAttrs attrs (builtins.filter (n: attrs.${n} == null) (builtins.attrNames attrs));
in
rec {
  /**
    Build a catalogue from one profile of a parsed manifest.

    Returns an attribute set with `all`, `addressable` and `ref`.

    # Type

    ```
    fromProfile :: String -> AttrSet -> Catalogue
    ```
  */
  fromProfile =
    profile: spec:
    let
      # Vault named by a provider entry, or null when that entry is another
      # backend.
      vaultOf =
        entry:
        let
          uri =
            if builtins.match ".*://.*" entry != null then
              entry
            else
              spec.providers.${entry} or (throw "secretspec declares no provider named ${entry}");
          host = firstJust (s: stripPrefix s uri) providerSchemes;
        in
        if host == null then null else dropUserinfo host;

      # Reference for one secret, or null when it has no 1Password address.
      addressOf =
        name: entry:
        if !(entry ? ref) || !(entry ? providers) || entry.providers == [ ] then
          null
        else
          let
            r = entry.ref;
            # ref.vault overrides the vault the provider URI names.
            vault = if r ? vault then r.vault else vaultOf (builtins.head entry.providers);
            section = if r ? section then [ r.section ] else [ ];
            parts = [
              vault
              r.item
            ]
            ++ section
            ++ [ r.field ];
          in
          if vault == null then
            null
          # A whole-item read has no field, so no field reference exists for it.
          else if !(r ? field) then
            if r ? section then throw "secretspec secret ${name} sets ref.section without ref.field" else null
          else if r ? version then
            throw "secretspec secret ${name} sets ref.version, which 1Password does not accept"
          else
            refScheme + builtins.concatStringsSep "/" parts;

      addresses = builtins.mapAttrs addressOf (spec.profiles.${profile} or { });
    in
    {
      /**
        Every secret in the profile
      */
      all = addresses;

      /**
        Only the secrets that have an `op://` address.
      */
      addressable = filterNull addresses;

      /**
        One address by name.

        Throws to avoid empty secrets that resolves to nothing.

        # Type

        ```
        ref :: String -> String
        ```
      */
      ref =
        name:
        if !(addresses ? ${name}) then
          throw "secretspec declares no secret named ${name}"
        else if addresses.${name} == null then
          throw "secretspec secret ${name} has no 1Password address: it declares no ref, names no provider, or uses another backend"
        else
          addresses.${name};
    };

  /**
    Build a catalogue from the `default` profile of a parsed manifest.

    # Type

    ```
    fromSpec :: AttrSet -> Catalogue
    ```
  */
  fromSpec = fromProfile profileName;

  /**
    Read a manifest from disk and build a catalogue from one profile.

    # Type

    ```
    readProfile :: String -> Path -> Catalogue
    ```
  */
  readProfile = profile: path: fromProfile profile (builtins.fromTOML (builtins.readFile path));

  /**
    Read a manifest from disk and build a catalogue from the `default` profile.

    # Type

    ```
    read :: Path -> Catalogue
    ```
  */
  read = readProfile profileName;

  /**
    Internals, exposed for tests and for callers composing their own view of a
    catalogue.
  */
  internal = {
    inherit
      stripPrefix
      filterNull
      firstJust
      dropUserinfo
      providerSchemes
      refScheme
      profileName
      ;
  };
}
