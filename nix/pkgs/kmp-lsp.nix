{ rustPlatform
, fetchFromGitHub
, lib
}:

rustPlatform.buildRustPackage rec {
  pname = "kmp-lsp";
  version = "0.24.0";

  # Was the cargo crate "kotlin-lsp" (Hessesian/kotlin-lsp); upstream renamed
  # the repo, crate, and binary to kmp-lsp (now Kotlin/Java/Swift).
  src = fetchFromGitHub {
    owner = "Hessesian";
    repo = "kmp-lsp";
    tag = "v${version}";
    hash = "sha256-8ebuSTXQL2y7PZOJc23I2Pph0M2XuiWYx0YHT2730ds=";
  };

  cargoHash = "sha256-22dTdeEg+IqW4QWKhRAdndx9UMo9tvHeUA17/EpseEM=";

  doCheck = false;

  meta = {
    description = "Fast, low-memory LSP server for Kotlin, Java, and Swift (no JVM required)";
    homepage = "https://github.com/Hessesian/kmp-lsp";
    license = lib.licenses.mit;
    mainProgram = "kmp-lsp";
  };
}
