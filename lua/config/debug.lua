local M = {}
local selected = {}

function M.root()
  local file = vim.api.nvim_buf_get_name(0)
  local start = file ~= "" and file or vim.fn.getcwd()
  return vim.fs.root(start, {
    ".vscode",
    "pyproject.toml",
    "setup.py",
    "requirements.txt",
    "CMakeLists.txt",
    "Makefile",
    ".git",
  }) or (file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd())
end

function M.python()
  local windows = vim.fn.has("win32") == 1
  local suffix = windows and "/Scripts/python.exe" or "/bin/python"
  local candidates = {}
  local selector = package.loaded["venv-selector"]
  if selector and selector.python() then
    table.insert(candidates, selector.python())
  end
  if vim.env.VIRTUAL_ENV then
    table.insert(candidates, vim.env.VIRTUAL_ENV .. suffix)
  end
  if vim.env.CONDA_PREFIX then
    table.insert(candidates, vim.env.CONDA_PREFIX .. (windows and "/python.exe" or suffix))
  end
  for _, dir in ipairs({ ".venv", "venv", "env", ".env" }) do
    table.insert(candidates, M.root() .. "/" .. dir .. suffix)
  end
  vim.list_extend(candidates, { "python3", "python" })
  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      return vim.fn.exepath(candidate)
    end
  end
  error("找不到 Python；请先安装 Python，或用 <leader>cv 选择虚拟环境")
end

-- This shortcut is for standalone exercises; project builds belong in the project's build system.
function M.build_file()
  local dap = require("dap")
  local file = vim.api.nvim_buf_get_name(0)
  local cpp = vim.bo.filetype == "cpp"
  local compiler
  for _, candidate in ipairs(cpp and { "clang++", "g++" } or { "clang", "gcc" }) do
    if vim.fn.executable(candidate) == 1 then
      compiler = candidate
      break
    end
  end
  if not compiler or file == "" then
    vim.notify("需要已保存的 C/C++ 文件和 clang/gcc 编译器", vim.log.levels.ERROR)
    return dap.ABORT
  end
  local dir = vim.fn.stdpath("cache") .. "/dap-build/" .. vim.fn.sha256(file):sub(1, 16)
  vim.fn.mkdir(dir, "p")
  local output = dir .. "/" .. vim.fn.fnamemodify(file, ":t:r") .. (vim.fn.has("win32") == 1 and ".exe" or "")
  local result = vim
    .system({ compiler, "-g", "-O0", "-Wall", "-Wextra", file, "-o", output }, {
      text = true,
      cwd = M.root(),
    })
    :wait()
  if result.code ~= 0 then
    vim.fn.setqflist({}, " ", {
      title = "Debug build",
      lines = vim.split((result.stdout or "") .. (result.stderr or ""), "\n"),
      efm = vim.o.errorformat,
    })
    vim.cmd.copen()
    vim.notify(
      "编译失败；多文件工程请先构建，再用 <leader>dd 选择可执行文件",
      vim.log.levels.ERROR
    )
    return dap.ABORT
  end
  return output
end

-- Bind workspace variables to the source project even when Neovim was opened elsewhere.
local function workspace(value, root)
  if type(value) == "table" then
    local result = {}
    for key, item in pairs(value) do
      result[key] = workspace(item, root)
    end
    return setmetatable(result, getmetatable(value))
  end
  if type(value) == "string" then
    value = value:gsub("%${workspaceFolder}", function()
      return root
    end)
    value = value:gsub("%${workspaceFolderBasename}", function()
      return vim.fs.basename(root)
    end)
    value = value:gsub("%${command:python.interpreterPath}", M.python)
  end
  return value
end

function M.start(opts)
  opts = opts or {}
  local dap = require("dap")
  if dap.session() and not opts.choose then
    dap.continue()
    return
  end
  -- Save before reading configurations/building so breakpoints match the file on disk.
  vim.cmd("silent update")
  local root, ft = M.root(), vim.bo.filetype
  local ok, project = pcall(require("dap.ext.vscode").getconfigs, root .. "/.vscode/launch.json")
  if not ok then
    vim.notify(project, vim.log.levels.ERROR)
    return
  end
  local types = {
    python = { python = true, debugpy = true },
    c = { codelldb = true, cppdbg = true },
    cpp = { codelldb = true, cppdbg = true },
  }
  project = vim.tbl_filter(function(config)
    return not types[ft] or types[ft][config.type]
  end, project)
  local defaults = dap.configurations[ft] or {}
  local configs = #project > 0 and project or defaults
  if opts.choose then
    configs = vim.list_extend(vim.deepcopy(project), defaults)
  elseif #project == 0 and not selected[root .. ft] and defaults[1] then
    configs = { defaults[1] }
  end
  local function run(config)
    if not config then
      return
    end
    if not dap.adapters[config.type] then
      vim.notify(
        "未配置调试器 " .. tostring(config.type) .. "；C/C++ 请使用 type: codelldb",
        vim.log.levels.ERROR
      )
      return
    end
    selected[root .. ft] = config.name
    -- Preserve launch.json input prompts, which nvim-dap resolves through __call.
    local launch = setmetatable({}, {
      __call = function()
        local mt = getmetatable(config)
        local resolved = workspace(mt and mt.__call and config() or vim.deepcopy(config), root)
        resolved.cwd = resolved.cwd or root
        if resolved.type == "codelldb" then
          resolved.expressions = resolved.expressions or "native"
        end
        if opts.args then
          resolved.args = require("dap.utils").splitstr(vim.fn.input("Arguments: "))
        end
        if opts.no_debug then
          resolved.noDebug = true
        end
        return resolved
      end,
    })
    dap.run(launch)
  end
  if not opts.choose then
    for _, config in ipairs(vim.list_extend(vim.deepcopy(project), defaults)) do
      if config.name == selected[root .. ft] then
        run(config)
        return
      end
    end
  end
  if #configs == 1 then
    run(configs[1])
  elseif #configs > 1 then
    vim.ui.select(configs, {
      prompt = "Debug configuration",
      format_item = function(c)
        return c.name
      end,
    }, run)
  else
    vim.notify("当前文件类型没有调试配置：" .. ft, vim.log.levels.WARN)
  end
end

return M
