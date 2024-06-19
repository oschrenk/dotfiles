-- https://github.com/nvim-telescope/telescope.nvim
-- fuzzy finder and picker over lists.
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").fd()
      end,
      desc = "Find files in project",
    },
    {
      "<leader>fF",
      function()
        require("telescope.builtin").find_files({ cwd = require("telescope.utils").buffer_dir() })
      end,
      desc = "Find files in cwd",
    },
    {
      "<leader>fd",
      function()
        require("telescope.builtin").diagnostics()
      end,
      desc = "Find diagnostics",
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
      desc = "Find help tags",
    },
    {
      "<leader>fr",
      function()
        require("telescope.builtin").oldfiles()
      end,
      desc = "Find recent files",
    },
    {
      "<leader>fm",
      function()
        require("telescope.builtin").marks()
      end,
      desc = "Find marks",
    },
    {
      "<leader>fw",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Find words",
    },
  },
  dependencies = {
    -- https://github.com/nvim-lua/plenary.nvim
    -- convenience lua functions
    "nvim-lua/plenary.nvim",

    -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
    -- c port of fzf for telescope
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    require("telescope").setup({
      pickers = {
        fd = {
          find_command = {
            "fd",
            "-I",
            "-H",
            "-E",
            "{.git,.svn,.hg,CSV,.DS_Store,Thumbs.db,node_modules,bower_components,*.code-search,target,.bloop,.idea}",
            "-t",
            "f",
          },
        },
      },
      defaults = {
        sorting_strategy = "ascending",
        layout_strategy = "flex",
        layout_config = {
          vertical = {
            preview_cutoff = 20,
          },
          horizontal = {
            preview_cutoff = 80,
          },
        },
        prompt_prefix = "  ",
        selection_caret = "  ",
        multi_icon = " ",
        winblend = 10,
        vimgrep_arguments = {
          "rg",
          "--hidden",
          "--glob=!{.git,.svn,.hg,CSV,.DS_Store,Thumbs.db,node_modules,bower_components,*.code-search}",
          "--ignore-case",
          "--with-filename",
          "--line-number",
          "--column",
          "--no-heading",
          "--trim",
          "--color=never",
        },
        buffer_previewer_maker = function(filepath, bufnr, opts)
          opts = opts or {}

          vim.loop.fs_stat(filepath, function(_, stat)
            if not stat or stat.size > 100000 then
              return
            end

            require("telescope.previewers").buffer_previewer_maker(filepath, bufnr, opts)
          end)
        end,
      },
      extensions = {
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- (default: "smart_case") or "ignore_case" or "respect_case"
        },
      },
    })
    require("telescope").load_extension("fzf")
  end,
}
