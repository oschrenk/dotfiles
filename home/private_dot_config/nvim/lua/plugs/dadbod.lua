return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    vim.g.db_ui_show_database_icon = 1
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_win_position = "left"
    vim.g.db_ui_winwidth = 30

    vim.g.db_ui_auto_execute_table_helpers = 1

    -- available templates
    -- {optional_schema}
    -- {table}
    vim.g.db_ui_table_helpers = {
      postgresql = {
        Count = "SELECT count(*) FROM {table}",
        Comment = "SHOW FULL COLUMNS FROM {table}",
        Describe = "DESC {table}",
        Explain = "EXPLAIN {last_query}",
        List = 'SELECT * FROM {table} LIMIT 100 OFFSET 0 * 100',
      },
    }
    vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sql", "mysql" },
    callback = function()
      require('cmp').setup.buffer(
        { sources = {
          { name = 'vim-dadbod-completion' },
          { name = 'buffer' }
        }}
      )
    end
    })
  end,
}
