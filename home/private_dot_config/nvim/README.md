# nvim

## Development

_Requirements_

- [stylua](https://github.com/JohnnyMorganz/StyLua) Lua formatter `brew install stylua`
- [tree-sitter-cli](https://github.com/tree-sitter/tree-sitter) Required by nvim-treesitter (main branch) to compile parsers `brew install tree-sitter-cli`

```
stylua .
```

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
4. `chezmoi add ~/.config/nvim/lazy-lock.json` to stage the changes
5. `chezmoi git diff` to verify exactly which commits changed
6. `chezmoi git -- commit -m "chore: update plugins"`

## Troubleshooting

- `:checkhealth` Check health of Neovim
- `:TSUpdate` Update treesitter parsers
- `:Lazy` Update dependencies

