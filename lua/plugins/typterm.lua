-- Opt in with vim.g.typterm_enabled = true in lua/config/options.lua.
-- The locally built project supplies this plugin; nothing is downloaded here.
local project = vim.fn.expand("~/Code/TypTerm")
return {
  {
    dir = project,
    name = "typterm.nvim",
    enabled = vim.g.typterm_enabled == true,
    ft = { "markdown", "typst", "tex", "plaintex" },
    cmd = { "TypTermPreview", "TypTermStop", "TypTermRefresh", "TypTermToggle" },
    init = function() vim.filetype.add({ extension = { typ = "typst" } }) end,
    opts = {
      command = project .. "/.build/debug/typterm",
      mode = "split", -- :TypTermPreview inline or <leader>tm switches mode
      debounce = 200,
      theme = "auto",
      inline_rows = 10,
      cell_aspect = 0.5, -- cell pixel width / height; adjust for your terminal font
    },
    config = function(_, opts) require("typterm").setup(opts) end,
    keys = {
      { "<leader>tp", function() require("typterm").open() end, desc = "TypTerm preview" },
      { "<leader>tm", function() require("typterm").toggle_mode() end, desc = "TypTerm split / inline" },
      { "<leader>tq", function() require("typterm").stop() end, desc = "TypTerm stop" },
      { "<leader>tj", function() require("typterm").scroll(4) end, desc = "TypTerm scroll down" },
      { "<leader>tk", function() require("typterm").scroll(-4) end, desc = "TypTerm scroll up" },
      { "<leader>tn", function() require("typterm").page(1) end, desc = "TypTerm next page" },
      { "<leader>tb", function() require("typterm").page(-1) end, desc = "TypTerm previous page" },
    },
  },
}
