# `nvim`

## Development

### Requirements

- [stylua](https://github.com/JohnnyMorganz/StyLua) Lua formatter, from `programs.stylua` in `nix/modules/home/stylua.nix`
- [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter) Required by nvim-treesitter (main branch) to compile parsers `brew install tree-sitter-cli`

```text
stylua .
```

stylua stops at the first config it finds and does not merge, so this file must stay complete.
It wins over the baseline in `~/.config/stylua/stylua.toml`.

## Nix

`blink.cmp` builds its fuzzy matcher with Rust (`cargo`), which is deliberately not on `PATH`.
The library filename ends in the checked-out commit.
Every `blink.cmp` update leaves the previous build unreachable, and completion falls back to the slower Lua matcher without an error.

Rebuild it after every update:

```sh
task nvim:blink
```

That runs `scripts/build-blink-fuzzy.sh`.
The script builds inside a throwaway `nix develop` shell that supplies `cargo`, `rustc`, and the linker.
It installs the dylib under the current commit hash and asks neovim whether the library loads.
It prints `library_available() reports true` on success and exits non-zero otherwise.

Check the state at any time with `:lua =require('blink.cmp').library_available()`.

### The Nix Toolchain and the Xcode 27 Linker

The Xcode 27 linker writes the `__LINKEDIT` string table at a 4-byte-aligned offset, but the macOS 26/27 loader requires 8-byte alignment, so `dlopen` rejects the result:

```text
mis-aligned LINKEDIT string pool, fileOffset=0x001A38BC
```

The build succeeds and the dylib then fails to load, so the script asks neovim rather than trusting the cargo exit code.
Every installed Xcode is on the 27 train, so there is no stable Apple linker to fall back to. nix's `ld64` links a dylib that loads, so the linker comes from nix rather than `xcode-select`.

`nix develop` matters over `nix shell` here: only `nix develop` runs the stdenv setup hook that puts the `libiconv` search path on `NIX_LDFLAGS`.
Rust links against `-liconv`, so a `nix shell` build finds iconv only when the caller already sets those flags, which a `fish` or `task` shell does not.
`mkShell` with `libiconv` in `buildInputs` is what supplies the path, so the build is self-sufficient and needs no linker override.

`:Lazy build blink.cmp` cannot fix the alignment problem, because it inherits the active Xcode.

## Plugin Security (Supply Chain)

Plugins are pinned via `lazy-lock.json`, which records the exact commit hash for every plugin.
Commit this file to git.
It is the source of truth, equivalent to `package-lock.json`.

**To install at pinned versions:**

```text
:Lazy restore
```

**To review and selectively update:**

1. `:Lazy check` to fetch upstream changes without installing
2. Press `l` on a plugin in the UI to inspect incoming commits
3. Press `u` on specific plugins to update only those you've reviewed
4. `git diff config/nvim/lazy-lock.json` to verify exactly which commits changed
5. `git commit -m "chore: update plugins"`

`~/.config/nvim` is a symlink to `config/nvim` in the dotfiles repository, so `lazy` writes the lockfile straight into the working copy.
There is no separate step to stage it.

## Troubleshooting

- `:checkhealth` Check health of Neovim
- `:TSUpdate` Update treesitter parsers
- `:Lazy` Update dependencies
