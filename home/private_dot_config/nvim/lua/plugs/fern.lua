return {
  "lambdalisue/fern.vim",
  lazy = false,
  dependencies = {
    {
      "lambdalisue/fern-renderer-nerdfont.vim",
      dependencies = { "lambdalisue/nerdfont.vim", "lambdalisue/glyph-palette.vim" },
      init = function()
        vim.api.nvim_set_var("fern#renderer", "nerdfont")
        vim.api.nvim_set_var("fern#renderer#nerdfont#root_symbol", "")
        vim.api.nvim_set_var("fern#renderer#nerdfont#root_leading", "")
        vim.api.nvim_set_var("fern#renderer#nerdfont#indent_markers", 1)
      end,
    },
    "lambdalisue/fern-git-status.vim",
  },
  init = function()
    vim.api.nvim_set_var("fern#default_hidden", 1)
    vim.api.nvim_set_var("fern#default_exclude", [[^\%(\.git\|\.svn\|\.hg\|\CVS\|\.DS_Store\|\Thumbs.db\)$]])
    vim.api.nvim_set_var("fern#disable_default_mappings", 1)
    vim.api.nvim_set_var("fern#disable_drawer_hover_popup", 1)
  end,
  config = function()
    vim.api.nvim_set_keymap("n", "-", "", {
      callback = function()
        vim.api.nvim_command("Fern . -reveal=% -drawer -toggle -right -width=50")
      end,
    })
    vim.api.nvim_exec(
      [[
      function! FernInit() abort
        nmap <buffer><expr>
          \ <Plug>(fern-my-open-expand-collapse)
          \ fern#smart#leaf(
          \   "\<Plug>(fern-action-open:select)",
          \   "\<Plug>(fern-action-expand)",
          \   "\<Plug>(fern-action-collapse)",
          \ )
        nmap <buffer> <CR> <Plug>(fern-my-open-expand-collapse)
        nmap <buffer> m <Plug>(fern-action-mark:toggle)j
        nmap <buffer> N <Plug>(fern-action-new-file)
        nmap <buffer> K <Plug>(fern-action-new-dir)
        nmap <buffer> D <Plug>(fern-action-remove)
        nmap <buffer> C <Plug>(fern-action-move)
        nmap <buffer> R <Plug>(fern-action-rename)
        nmap <buffer> r <Plug>(fern-action-reload)
        nmap <buffer> <nowait> d <Plug>(fern-action-hidden:toggle)
      endfunction

      augroup FernEvents
        autocmd!
        autocmd FileType fern call FernInit()
      augroup END

      augroup FernTypeGroup
          autocmd! * <buffer>
          autocmd BufEnter <buffer> silent execute "normal \<Plug>(fern-action-reload)"
      augroup END
      ]], false
    )
  end,
}
