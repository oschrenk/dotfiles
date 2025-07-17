# https://github.com/mozanunal/sllm.nvim

return {
  "mozanunal/sllm.nvim",
  lazy = false,
  dependencies = {
    "folke/snacks.nvim"
  },
  keys = {
    {
      "<leader>as",
      function()
        require("sllm").ask_llm()
      end,
      desc = "Ask llm",
    },
    {
      "<leader>aa",
      function()
        require("sllm").add_file_to_ctx()
      end,
      desc = "Add file to context",
    },
    {
      "<leader>av",
      function()
        require("sllm").add_sel_to_ctx()
      end,
      desc = "Add selection to context",
    },
  },
  config = function()
    require("sllm").setup({
      keymaps = false,
      llm_cmd = "/opt/homebrew/bin/llm",
      pick_func = require("snacks.picker").select,
      notify_func = require("snacks.notifier").notify
    })
  end,
}
