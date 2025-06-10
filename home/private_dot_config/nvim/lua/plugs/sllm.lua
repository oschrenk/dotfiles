# https://github.com/mozanunal/sllm.nvim

return {
  "mozanunal/sllm.nvim",
  dependencies = {
    "folke/snacks.nvim"
  },
  keys = {
    {
      "<leader>ss",
      function()
        require("sllm").ask_llm()
      end,
      desc = "Ask llm",
    },
  },
  config = function()
    require("sllm").setup({
      pick_func = require("snacks.picker").select,
      notify_func = require("snacks.notifier").notify
    })
  end,
}
