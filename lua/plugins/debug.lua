return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "debugpy", "codelldb" } },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = { handlers = { codelldb = function() end } },
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      local debug = require("config.debug")
      local python = require("dap-python")
      -- Run the adapter in Mason's environment; run the user's code in its own environment.
      local adapter_python = vim.fn.stdpath("data")
        .. "/mason/packages/debugpy/venv/"
        .. (vim.fn.has("win32") == 1 and "Scripts/python.exe" or "bin/python")
      python.setup(adapter_python, { include_configs = false })
      python.resolve_python = debug.python
      require("dap").configurations.python = {
        {
          name = "Python: Current File",
          type = "python",
          request = "launch",
          program = "${file}",
          cwd = debug.root,
          pythonPath = debug.python,
          console = "integratedTerminal",
          justMyCode = true,
        },
      }
    end,
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      -- CodeLLDB >= 1.11 supports stdio, avoiding localhost/IPv6 connection issues.
      dap.adapters.codelldb = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb" .. (vim.fn.has(
          "win32"
        ) == 1 and ".exe" or ""),
      }
      for _, ft in ipairs({ "c", "cpp" }) do
        table.insert(dap.configurations[ft], 1, {
          name = "C/C++: Build and Debug Current File",
          type = "codelldb",
          request = "launch",
          program = require("config.debug").build_file,
          cwd = require("config.debug").root,
          stopOnEntry = false,
          terminal = "integrated",
        })
      end
    end,
    -- Function keys match VS Code; leader mappings also work without terminal Fn support.
    -- stylua: ignore
    keys = {
      { "<F5>", function() require("config.debug").start() end, desc = "Debug: Start / Continue", mode = { "n", "i" } },
      { "<C-F5>", function() require("config.debug").start({ no_debug = true }) end, desc = "Run Without Debugging", mode = { "n", "i" } },
      { "<S-F5>", function() require("dap").terminate() end, desc = "Debug: Stop", mode = { "n", "i" } },
      { "<C-S-F5>", function() vim.cmd("silent update"); require("dap").restart() end, desc = "Debug: Restart", mode = { "n", "i" } },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint", mode = { "n", "i" } },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over", mode = { "n", "i" } },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into", mode = { "n", "i" } },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Step Out", mode = { "n", "i" } },
      { "<leader>dc", function() require("config.debug").start() end, desc = "Start / Continue" },
      { "<leader>dd", function() require("config.debug").start({ choose = true }) end, desc = "Choose Debug Configuration" },
      { "<leader>da", function() require("config.debug").start({ args = true }) end, desc = "Run with Args" },
      { "<leader>dR", function() vim.cmd("silent update"); require("dap").restart() end, desc = "Restart Debugging" },
      { "<leader>dn", function() require("config.debug").start({ no_debug = true }) end, desc = "Run Without Debugging" },
      { "<leader>dx", function() require("dap").clear_breakpoints() end, desc = "Clear All Breakpoints" },
      { "<leader>dL", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: ")) end, desc = "Set Logpoint" },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    opts = {
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.40 },
            { id = "watches", size = 0.20 },
            { id = "stacks", size = 0.20 },
            { id = "breakpoints", size = 0.20 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } },
          size = 12,
          position = "bottom",
        },
      },
    },
    config = function(_, opts)
      local dap, ui = require("dap"), require("dapui")
      ui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        ui.open()
      end
      -- Keep the console/output readable when the program exits. <leader>du closes the UI.
      dap.listeners.before.event_terminated["dapui_config"] = nil
      dap.listeners.before.event_exited["dapui_config"] = nil
    end,
  },
}
