require('telescope').setup{
	defaults = {
    layout_strategy = "flex",
    layout_config = {
      vertical = {
        preview_cutoff = 20,
      },
      horizontal = {
        preview_cutoff = 80,
      },
    },
		path_display={"smart"},
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new
	},
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- (default: "smart_case") or "ignore_case" or "respect_case"
    },
    heading = {
      treesitter = true,
    },
  }
}

require('telescope').load_extension('fzf')
require('telescope').load_extension('heading')
