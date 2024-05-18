-- https://github.com/David-Kunz/gen.nvim
-- interact with local llm
return {
  "David-Kunz/gen.nvim",
  cmd = "Gen",
  keys = {
    {
      "<leader>la",
      mode = { "n", "x", "o" },
      "<cmd>Gen Ask<CR>",
      desc = "Ask",
    },
  },
  opts = {
    -- see available models at https://ollama.com/library
    model = "mistral", -- default model
    host = "localhost", -- host running Ollama service.
    port = "11434", -- port of Ollama service
    retry_map = "<c-r>", -- set keymap to re-send the current prompt
    display_mode = "split", -- display mode. Can be "float" or "split"
    show_prompt = true, -- Show submitted prompt
    show_model = true, -- Display used model
    no_auto_close = true, -- Never auto-close window
    debug = false, -- Print errors
  },
}
