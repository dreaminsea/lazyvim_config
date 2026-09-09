return {
  {
    "stevearc/aerial.nvim",
    main = "aerial",
    opts = function(_, opts)
      opts.filter_kind = false
      return opts
    end,
  },
}
