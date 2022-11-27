require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "bash", "fish",
    "html", "css",
    "lua", "vim",
    "python",
    "scala", "hocon",
    "markdown", "rst",
    "javascript", "json", "typescript", "tsx",
    "hcl"
  },
  highlight = {
    enable = true,
    -- can be boolean or list of languages
    additional_vim_regex_highlighting = false,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  },
  markid = {
    enable = true
  }
}
