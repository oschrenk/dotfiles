-- https://github.com/ellisonleao/gruvbox.nvim
-- lua implementation of gruvbox
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false, -- make sure to load this during startup
  priority = 1000, -- make sure to load this before all other plugins
  config = function()
    require("gruvbox").setup({
      overrides = {
        SignColumn = { bg = "#282828" },
        FoldColumn = { bg = "#282828" },

        -- this is
        --  - sidebar: the submit button & token counter
        --  - popup:   the submit
        -- the sidebar is dark1=#3c3836, and that is more important
        -- so we make
        --  - AvantePromptInput and
        --  - AvantePromptInputBorder
        -- both also dark1=#3c3836
        -- but this actually relies on a patch
        -- and removing
        --    api.nvim_set_option_value("winblend", 5, { win = winid })
        --    api.nvim_set_option_value("cursorline", true, { win = winid })
        -- in lua/avante/ui/prompt_input.lua
        AvantePopupHint = { bg = "#3c3836" },
        AvantePromptInput = { bg = "#3c3836" },
        AvantePromptInputBorder = { bg = "#3c3836" },
        -- this is unfortunately the title highlight group in Avante popups
        -- to make the Prompt popup consistent we also make it
        -- dark1=#3c3836
        FloatTitle = { bg = "#3c3836" },
      },
    })
    vim.cmd("colorscheme gruvbox")
  end,
}
