-- https://github.com/jackMort/ChatGPT.nvim
-- interact with chatgpt
-- requirements
--
-- 1. curl (`brew install curl`)
-- 2. an API key via https://platform.openai.com/api-keys
return {
  "jackMort/ChatGPT.nvim",
  cmd = { "ChatGPT", "ChatGPTRun" },
  config = function()
    require("chatgpt").setup({
      api_key_cmd = "op read op://Personal/auth0.openai.com/2jesovznfbi6yodj6cnb2azgg4 --no-newline",
      openai_params = {
        model = "gpt-3.5-turbo",
        frequency_penalty = 0,
        presence_penalty = 0,
        max_tokens = 1000,
        temperature = 0,
        top_p = 1,
        n = 1,
      },
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim",
  },
  init = function()
    local wk = require("which-key")
    wk.register({
      c = {
        name = "+ChatGPT",
        c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
        g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
        t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
        k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
        d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
        a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
        o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
        s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
        f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
        x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
        r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
        l = {
          "<cmd>ChatGPTRun code_readability_analysis<CR>",
          "Code Readability Analysis",
          mode = { "n", "v" },
        },
      },
    }, { prefix = "<leader>" })
  end,
}
