# 💤 LazyVim

This is my Neovim config based on LazyVim

## 调试（Python / C / C++）

打开源文件，按 `F9` 打断点，再按 `F5`。启动前自动保存当前文件，调试时左侧显示变量、监视、调用栈和断点，底部显示调试控制台和程序终端。程序结束后面板保留，可用 `<Space>du` 收起。

| 操作 | VS Code 风格按键 | 普通模式备用键 |
| --- | --- | --- |
| 启动 / 继续 | `F5` | `<Space>dc` |
| 切换断点 | `F9` | `<Space>db` |
| 单步跳过 | `F10` | `<Space>dO` |
| 单步进入 | `F11` | `<Space>di` |
| 单步跳出 | `Shift+F11` | `<Space>do` |
| 停止 | `Shift+F5` | `<Space>dt` |
| 重启当前会话 | `Ctrl+Shift+F5` | `<Space>dR` |
| 不停断点运行 | `Ctrl+F5` | `<Space>dn` |
| 选择调试配置 | — | `<Space>dd` |
| 输入启动参数 | — | `<Space>da` |
| 查看光标下变量 / 选中表达式 | — | `<Space>de` |
| 条件断点 / 日志断点 | — | `<Space>dB` / `<Space>dL` |
| 清空断点 | — | `<Space>dx` |

功能键在普通和插入模式均可用。macOS 若把 F 键用作亮度/音量键，需要同时按 `Fn`；终端无法传递组合功能键时使用备用键。程序终端支持 `input()` / `scanf` / `cin`，按 `i` 输入，`Ctrl+\` 后按 `Ctrl+n` 返回普通模式。

- **Python**：默认运行当前文件。优先使用手动选择或已激活的环境，然后查找项目 `.venv` / `venv` / `env` / `.env`，最后使用 PATH 中的 Python。用 `<Space>cv` 选择其他解释器；使用 uv 的项目先执行 `uv sync`。调试器由 Mason 独立安装，项目环境无需额外安装 debugpy。
- **独立 C/C++ 文件**：默认用 clang/gcc（C++ 用 clang++/g++），以 `-g -O0` 编译到 Neovim 缓存目录后启动。需安装编译器。编译错误显示在 quickfix 中；`<Space>xq` 可切换该窗口。
- **多文件 C/C++ 工程**：先用项目的 Make/CMake 等工具构建带调试信息的程序，再用 `<Space>dd` 选择 `Launch file` 并填写可执行文件路径。修改源码后需重新构建；会话重启只重启现有程序。

C/C++ 的监视表达式默认使用原生 C/C++ 语法；调试控制台中用 `?变量或表达式` 求值，例如 `?value + 2`，也可以直接输入 LLDB 命令。参见 [CodeLLDB 控制台说明](https://github.com/vadimcn/codelldb/blob/master/MANUAL.md#debug-console)。

项目中的 `.vscode/launch.json` 优先于默认配置；有多个配置时首次选择，之后在当前 Neovim 进程中记住选择，`<Space>dd` 可切换。支持 `python` / `debugpy` 和 `codelldb`，并识别项目根目录的 `${workspaceFolder}`。VS Code 专属任务 `preLaunchTask` / `tasks.json`、扩展命令和 `cppdbg` 不能直接复用（Python 的 `${command:python.interpreterPath}` 已做兼容）。

例如在项目根目录创建 `.vscode/launch.json`，固定 Python 入口或 C/C++ 可执行文件：

```jsonc
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: main.py",
      "type": "debugpy",
      "request": "launch",
      "program": "${workspaceFolder}/main.py",
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal",
      "justMyCode": true,
      "args": []
    },
    {
      "name": "C/C++: project",
      "type": "codelldb",
      "request": "launch",
      "program": "${workspaceFolder}/build/main",
      "cwd": "${workspaceFolder}",
      "terminal": "integrated",
      "args": []
    }
  ]
}
```

同步到新机器后，LazyVim/Mason 会安装所需插件与 `debugpy`、`codelldb`。若下载失败，执行 `:MasonInstall debugpy codelldb`，安装完成后重启 Neovim。
