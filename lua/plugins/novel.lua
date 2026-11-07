local checkout = vim.fn.expand("~/Code/novel.nvim")

return {
  {
    "dreaminsea/novel.nvim",
    -- Develop locally when the checkout exists; install from GitHub elsewhere.
    dir = vim.fn.isdirectory(checkout .. "/lua/novel") == 1 and checkout or nil,
    main = "novel",
    cmd = { "Novel" },
    opts = {
      sidebar = { width = 38 },
      export = { pandoc = "pandoc", pdf_engine = "xelatex" },
    },
    keys = {
      { "<leader>Np", "<cmd>Novel toggle<cr>", desc = "Writing project" },
      { "<leader>Ni", "<cmd>Novel init<cr>", desc = "New writing project" },
      { "<leader>No", "<cmd>Novel open<cr>", desc = "Open writing project" },
      { "<leader>Nn", "<cmd>Novel new<cr>", desc = "New sheet" },
      { "<leader>Ng", "<cmd>Novel group<cr>", desc = "New group" },
      { "<leader>Ne", "<cmd>Novel export<cr>", desc = "Export writing project" },
      { "<leader>Ns", "<cmd>Novel stats<cr>", desc = "Writing statistics" },
      { "<leader>Nm", "<cmd>Novel metadata<cr>", desc = "Project metadata" },
    },
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = { spec = { { "<leader>N", group = "novel" } } },
  },
}
