return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    opts = {
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_ignored = false,
          -- Hide known caches and metadata without hiding other ignored files.
          hide_by_name = {
            ".git",
            ".DS_Store",
            "thumbs.db",
            "__pycache__",
            ".pytest_cache",
            ".mypy_cache",
            ".ruff_cache",
            ".hypothesis",
            ".cache",
            ".ipynb_checkpoints",
            ".parcel-cache",
            ".turbo",
            ".eslintcache",
            ".stylelintcache",
          },
          hide_by_pattern = {
            "*.pyc",
            "*.pyo",
            "*.swp",
            "*.swo",
          },
        },
      },
    },
  },
}
