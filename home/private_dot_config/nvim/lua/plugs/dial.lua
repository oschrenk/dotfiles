-- https://github.com/monaqa/dial.nvim
-- enhance increment/decrement behaviour
return {
  "monaqa/dial.nvim",
  keys = {
    { "<C-a>", "<Plug>(dial-increment)", mode = "n", desc = "Increment value" },
    { "<C-x>", "<Plug>(dial-decrement)", mode = "n", desc = "Decrement value" },
    { "<C-a>", "<Plug>(dial-increment)", mode = "v", desc = "Increment value" },
    { "<C-x>", "<Plug>(dial-decrement)", mode = "v", desc = "Decrement value" },
  },
  config = function()
    local augend = require("dial.augend")
    local config = require("dial.config")

    local operators = augend.constant.new({
      elements = { "&&", "||" },
      word = false,
      cyclic = true,
    })

    local casing = augend.case.new({
      types = { "camelCase", "snake_case", "PascalCase", "SCREAMING_SNAKE_CASE" },
      cyclic = true,
    })

    config.augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.hexcolor.new({
          case = "lower",
        }),
        augend.date.alias["%Y-%m-%d"],
        augend.constant.alias.bool,
        casing,
      },
    })

    config.augends:on_filetype({
      go = {
        operators,
      },
      typescript = {
        augend.constant.new({ elements = { "let", "const" } }),
      },
      markdown = {
        augend.misc.alias.markdown_header,
      },
      yaml = {
        augend.semver.alias.semver,
      },
      toml = {
        augend.semver.alias.semver,
      },
    })
  end,
}
