-- Copy this file to ~/.config/nvim/lua/plugins/typterm.lua after building.
-- The project supplies this plugin; it does not download another plugin.
local project = vim.fn.expand("~/Code/TypTerm")
return {
  {
    dir = project,
    name = "typterm.nvim",
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
