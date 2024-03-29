return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").fd()
      end,
    },
    {
      "<leader>fh",
      function()
        require("telescope.builtin").help_tags()
      end,
    },
    {
      "<leader>of",
      function()
        require("telescope.builtin").oldfiles()
      end,
    },
    {
      "<leader>mf",
      function()
        require("telescope.builtin").marks()
      end,
    },
    {
      "<leader>wf",
      function()
        require("telescope.builtin").live_grep()
      end,
    },
    {
      "<leader>gf",
      function()
        require("telescope.builtin").git_status()
      end,
    },
    {
      "z=",
      function()
        require("telescope.builtin").spell_suggest()
      end,
    },
  },
  dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
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
