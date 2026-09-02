# `nvim`

## Development

### Requirements

- [stylua](https://github.com/JohnnyMorganz/StyLua) Lua formatter, from `nixpkgs`
- [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter) Required by nvim-treesitter (main branch) to compile parsers `brew install tree-sitter-cli`

```text
stylua .
```

## Nix

`blink.cmp` builds its fuzzy matcher with Rust (`cargo`), which is deliberately not on `PATH`.
The library filename ends in the checked-out commit.
Every `blink.cmp` update leaves the previous build unreachable, and completion falls back to the slower Lua matcher without an error.

Rebuild it after every update:

```sh
task nvim:blink
```

That runs `scripts/build-blink-fuzzy.sh`.
The script takes `cargo` and `rustc` from a throwaway `nix shell`, then links against stable Xcode.
It installs the dylib under the current commit hash and asks neovim whether the library loads.
It prints `library_available() reports true` on success and exits non-zero otherwise.

Check the state at any time with `:lua =require('blink.cmp').library_available()`.

### Xcode 27 Beta Linker Breaks the Build

Nix only provides `cargo` and `rustc`.
The linker still comes from whatever `xcode-select -p` points at.
The Xcode 27 beta linker (`ld-27034`) writes the `__LINKEDIT` string table at a 4-byte-aligned offset, but macOS 26/27's loader requires 8-byte alignment, so `dlopen` rejects the result:

```text
mis-aligned LINKEDIT string pool, fileOffset=0x001A38BC
```

The build succeeds and the dylib then fails to load.
So the script asks neovim rather than trusting the cargo exit code.
`:Lazy build blink.cmp` cannot fix this, because it inherits the same active Xcode.
The script points `DEVELOPER_DIR` and the cargo linker variable at stable Xcode (26.6, `ld-1267`) instead, and leaves the system-wide `xcode-select` choice alone.

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
