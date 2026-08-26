# nvim

## Development

_Requirements_

- [stylua](https://github.com/JohnnyMorganz/StyLua) Lua formatter `brew install stylua`
- [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter) Required by nvim-treesitter (main branch) to compile parsers `brew install tree-sitter-cli`

```
stylua .
```

## Nix

`blink.cmp` builds its fuzzy matcher with Rust (`cargo`). If Rust isn't installed,
get a temporary shell that leaves `PATH` untouched afterwards:

```sh
nix shell nixpkgs#cargo nixpkgs#rustc
nvim   # :Lazy update blink.cmp  (or :Lazy build blink.cmp)
exit
```

### Xcode 27 beta linker breaks the build

Nix only provides `cargo`/`rustc` — the linker still comes from whatever
`xcode-select -p` points at. The Xcode 27 beta linker (`ld-27034`) writes the
`__LINKEDIT` string table at a 4-byte-aligned offset, but macOS 26/27's loader
requires 8-byte alignment, so `dlopen` rejects the result:

```
mis-aligned LINKEDIT string pool, fileOffset=0x001A38BC
```

`:Lazy build blink.cmp` won't help — it inherits the same active Xcode. Build
against stable Xcode (26.6, `ld-1267`) instead:

```sh
cd ~/.local/share/nvim/lazy/blink.cmp
nix shell nixpkgs#cargo nixpkgs#rustc
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
    CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang \
    cargo build --release
mv target/release/libblink_cmp_fuzzy.dylib \
   "lib/libblink_cmp_fuzzy.dylib.$(git rev-parse HEAD | cut -c1-7)"
exit
```

The library filename is keyed to the checked-out commit, so repeat this after
every `blink.cmp` update. Verify with `:lua =require('blink.cmp').library_available()`.

## Plugin Security (Supply Chain)

Plugins are pinned via `lazy-lock.json`, which records the exact commit hash for every plugin. Commit this file to git — it is the source of truth, equivalent to `package-lock.json`.

**To install at pinned versions:**
```
:Lazy restore
```

**To review and selectively update:**
1. `:Lazy check` — fetch upstream changes without installing
2. Press `l` on a plugin in the UI to inspect incoming commits
3. Press `u` on specific plugins to update only those you've reviewed
4. `git diff config/nvim/lazy-lock.json` to verify exactly which commits changed
5. `git commit -m "chore: update plugins"`

`~/.config/nvim` is a symlink to `config/nvim` in the dotfiles repository, so
`lazy` writes the lockfile straight into the working copy. There is no separate
step to stage it.

## Troubleshooting

- `:checkhealth` Check health of Neovim
- `:TSUpdate` Update treesitter parsers
- `:Lazy` Update dependencies

