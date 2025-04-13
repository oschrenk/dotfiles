-- https://github.com/ellisonleao/gruvbox.nvim
-- lua implementation of gruvbox
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false, -- make sure to load this during startup
  priority = 1000, -- make sure to load this before all other plugins
  config = function()
    local palette = require("gruvbox").palette

    require("gruvbox").setup({
      overrides = {
        SignColumn = { bg = palette.dark0 },
        FoldColumn = { bg = palette.dark0 },
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
        AvantePopupHint = { bg = palette.dark1 },
        AvantePromptInput = { bg = palette.dark1 },
        AvantePromptInputBorder = { bg = palette.dark1 },
        -- this is unfortunately the title highlight group in Avante popups
        -- to make the Prompt popup consistent we also make it
        -- dark1=#3c3836
        FloatTitle = { bg = palette.dark1 },
        -- Avante sidebar also messes with the CursorColumn highlighting
        -- so we pin it to palette.dark1
        CursorLine = { bg = palette.dark1 },
        CursorColumn = { bg = palette.dark1 },

        -- original fg="#98c379"
        AvanteTitle = { fg = palette.dark1, bg = palette.bright_green },
        AvanteReversedTitle = { fg = palette.bright_green, bg = palette.dark1 },

        -- original color = "#56b6c2"
        AvanteSubtitle = { fg = palette.dark1, bg = palette.bright_yellow },
        AvanteReversedSubtitle = { fg = palette.bright_yellow, bg = palette.dark1 },

        -- original color = "#353B45"
        AvanteThirdTitle = { fg = palette.dark1, bg = palette.bright_blue },
        AvanteReversedThirdTitle = { fg = palette.bright_blue, bg = palette.dark1 },
      },
    })
    vim.cmd("colorscheme gruvbox")
  end,
}
