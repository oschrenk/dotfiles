# https://secretspec.dev/providers/onepassword/
#
# Unit tests for the secretspec catalogue reader in secrets.nix.
#
# Run with: nix flake check ./nix
#
{ lib }:
let
  secrets = import ../secrets.nix;

  providers = {
    main = "onepassword://Vault";
    spaced = "onepassword://Two Words";
    ring = "keyring://";
    local = "dotenv://.env";
  };

  build =
    entries:
    (secrets.fromSpec {
      inherit providers;
      profiles.default = entries;
    }).all;

  # For specs that declare more than one profile
  build2 = spec: (secrets.fromSpec (spec // { inherit providers; })).all;

  throws = e: !(builtins.tryEval (builtins.deepSeq e e)).success;
in
lib.runTests {
  testFlatField = {
    expr = build {
      A = {
        providers = [ "main" ];
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
    };
    expected = {
      A = "op://Vault/Item/a-field";
    };
  };

  testSectionIsInserted = {
    expr = build {
      A = {
        providers = [ "main" ];
        ref = {
          item = "dotted.example";
          section = "API";
          field = "token";
        };
      };
    };
    expected = {
      A = "op://Vault/dotted.example/API/token";
    };
  };

  testSpacesSurviveInVaultItemAndField = {
    expr = build {
      A = {
        providers = [ "spaced" ];
        ref = {
          item = "Spaced Item";
          section = "Sub";
          field = "Spaced Field";
        };
      };
    };
    expected = {
      A = "op://Two Words/Spaced Item/Sub/Spaced Field";
    };
  };

  # A defaulted secret carries no coordinates. Yielding null keeps it out of
  # the opnix declarations instead of addressing "op://Vault//".
  testEntryWithoutRefIsNull = {
    expr = build {
      A = {
        description = "no ref";
        default = "false";
      };
    };
    expected = {
      A = null;
    };
  };

  testEntryWithoutProvidersIsNull = {
    expr = build {
      A = {
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
    };
    expected = {
      A = null;
    };
  };

  # The first provider wins, because op:// addresses exactly one vault while
  # secretspec treats the list as a fallback chain.
  testFirstProviderWins = {
    expr = build {
      A = {
        providers = [
          "spaced"
          "main"
        ];
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
    };
    expected = {
      A = "op://Two Words/Item/a-field";
    };
  };

  testEmptyProviderListIsNull = {
    expr = build {
      A = {
        providers = [ ];
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
    };
    expected = {
      A = null;
    };
  };

  # A secret served by another backend is not an error.
  testNonOnePasswordProviderIsNull = {
    expr = build {
      A = {
        providers = [ "ring" ];
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
    };
    expected = {
      A = null;
    };
  };

  testDotenvProviderIsNull = {
    expr = build {
      A = {
        providers = [ "local" ];
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
    };
    expected = {
      A = null;
    };
  };

  # The mixed case: a 1Password entry beside a keyring entry resolves the first and ignores the second.
  testMixedBackendsResolveIndependently = {
    expr = build {
      OPS = {
        providers = [ "main" ];
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
      DEV = {
        providers = [ "ring" ];
        ref = {
          item = "Another Item";
          field = "token";
        };
      };
    };
    expected = {
      OPS = "op://Vault/Item/a-field";
      DEV = null;
    };
  };

  # Asking for a non-1Password secret by name fails
  testRefOnNonOnePasswordSecretThrows = {
    expr = throws (
      (secrets.fromSpec {
        inherit providers;
        profiles.default.A = {
          providers = [ "ring" ];
          ref = {
            item = "Item";
            field = "a-field";
          };
        };
      }).ref
        "A"
    );
    expected = true;
  };

  testUnknownSecretNameThrows = {
    expr = throws (
      (secrets.fromSpec {
        inherit providers;
        profiles.default = { };
      }).ref
        "NOPE"
    );
    expected = true;
  };

  testRefOnNullEntryThrows = {
    expr = throws (
      (secrets.fromSpec {
        inherit providers;
        profiles.default.A = {
          default = "x";
        };
      }).ref
        "A"
    );
    expected = true;
  };

  ###################
  # Profiles
  ###################

  # A secret under another profile is absent from `all`, so nothing generates a
  # declaration for it. That is deliberate: an op:// address names exactly one
  # coordinate, and reading every profile would silently pick a winner.
  testNonDefaultProfileIsNotRead = {
    expr = build2 {
      profiles.default.A = {
        providers = [ "main" ];
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
      profiles.production.B = {
        providers = [ "main" ];
        ref = {
          item = "Elsewhere Item";
          field = "token";
        };
      };
    };
    expected = {
      A = "op://Vault/Item/a-field";
    };
  };

  # Asking for a secret that exists only in another profile fails
  testSecretInAnotherProfileThrows = {
    expr = throws (
      (secrets.fromSpec {
        inherit providers;
        profiles.production.B = {
          providers = [ "main" ];
          ref = {
            item = "Elsewhere Item";
            field = "token";
          };
        };
      }).ref
        "B"
    );
    expected = true;
  };

  # The same name in two profiles resolves per profile, which is the whole
  # reason only one is read.
  testProfileSelectsItsOwnValue = {
    expr =
      (secrets.fromProfile "production" {
        inherit providers;
        profiles.default.A = {
          providers = [ "main" ];
          ref = {
            item = "DevItem";
            field = "token";
          };
        };
        profiles.production.A = {
          providers = [ "main" ];
          ref = {
            item = "ProdItem";
            field = "token";
          };
        };
      }).all;
    expected = {
      A = "op://Vault/ProdItem/token";
    };
  };

  testMissingProfileIsEmpty = {
    expr =
      (secrets.fromProfile "nope" {
        inherit providers;
        profiles.default = { };
      }).all;
    expected = { };
  };

  ###################
  # Default provider
  ###################

  # An entry naming no provider falls back to the user-global default, which is
  # null:// here. That is not a vault, so it has no op:// address and is not an
  # opnix secret. It stays in the catalogue as null rather than disappearing.
  testDefaultProviderEntryIsNullNotMissing = {
    expr = build {
      DEFAULTED = {
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
      ADDRESSED = {
        providers = [ "main" ];
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
    };
    expected = {
      DEFAULTED = null;
      ADDRESSED = "op://Vault/Item/a-field";
    };
  };

  # A provider named in an entry but absent from [providers] is a typo, and
  # must not resolve to a vault called "null".
  testUnknownProviderNameThrows = {
    expr = throws (build {
      A = {
        providers = [ "typo" ];
        ref = {
          item = "Item";
          field = "a-field";
        };
      };
    });
    expected = true;
  };

  # The real manifest has to keep producing what the hosts already expect.
  testRealManifestResolvesNtfy = {
    expr = (secrets.read ../../secretspec.toml).ref "NTFY_HOMELAB_BACKUPS_URL";
    expected = "op://Homelab/Ntfy/homelab-backups";
  };

  # The provider URI scheme and the reference scheme are different strings, and
  # conflating them yields onepassword://... which opnix cannot resolve.
  testReferenceSchemeIsNotAProviderScheme = {
    expr = builtins.elem secrets.internal.refScheme secrets.internal.providerSchemes;
    expected = false;
  };

  ###################
  # Shapes the manifest format allows
  ###################

  # An inline URI in place of an alias is the documented idiom for a one-off.
  testInlineProviderUri = {
    expr = build {
      A = {
        providers = [ "onepassword://Production" ];
        ref = {
          item = "db";
          field = "password";
        };
      };
    };
    expected = {
      A = "op://Production/db/password";
    };
  };

  testTokenSchemeIsRecognised = {
    expr = build {
      A = {
        providers = [ "onepassword+token://Ops" ];
        ref = {
          item = "db";
          field = "password";
        };
      };
    };
    expected = {
      A = "op://Ops/db/password";
    };
  };

  # onepassword://account@Vault names an account and a vault; only the vault
  # belongs in a reference.
  testAccountIsDroppedFromVault = {
    expr = build {
      A = {
        providers = [ "onepassword://work@DevVault" ];
        ref = {
          item = "db";
          field = "password";
        };
      };
    };
    expected = {
      A = "op://DevVault/db/password";
    };
  };

  # ref.vault overrides whatever vault the provider names.
  testRefVaultOverridesProvider = {
    expr = build {
      A = {
        providers = [ "main" ];
        ref = {
          vault = "Elsewhere";
          item = "db";
          field = "password";
        };
      };
    };
    expected = {
      A = "op://Elsewhere/db/password";
    };
  };

  # A ref naming only an item is a whole-item read. No field reference exists
  # for it, so it is unaddressable rather than guessed at.
  testItemWithoutFieldIsNull = {
    expr = build {
      A = {
        providers = [ "main" ];
        ref = {
          item = "db";
        };
      };
    };
    expected = {
      A = null;
    };
  };

  # secretspec rejects a section without a field, so this is a manifest error
  # rather than something to render.
  testSectionWithoutFieldThrows = {
    expr = throws (build {
      A = {
        providers = [ "main" ];
        ref = {
          item = "db";
          section = "API";
        };
      };
    });
    expected = true;
  };

  # 1Password does not accept a version coordinate.
  testVersionThrows = {
    expr = throws (build {
      A = {
        providers = [ "main" ];
        ref = {
          item = "db";
          field = "password";
          version = "3";
        };
      };
    });
    expected = true;
  };

  # The refs table is not supported. Treating it as unaddressable
  testRefsTableIsUnaddressable = {
    expr = build {
      A = {
        providers = [ "main" ];
        refs.main = {
          item = "db";
          field = "password";
        };
      };
    };
    expected = {
      A = null;
    };
  };
}
