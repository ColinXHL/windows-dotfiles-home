# Neovim Development Environment

This is a project-oriented LazyVim configuration for C++ development over SSH.
It uses Catppuccin Mocha with a transparent editor background, terminal-native
Markdown rendering, clangd, CMake language support, and a deliberately small
set of primary keys.

On Windows, the LazyVim bootstrap uses Git from `PATH` and falls back to
`C:\Program Files\Git\cmd\git.exe`. This keeps first launch working from a
terminal process that was opened before Git updated the system `PATH`.

## Project Workflow

Start Neovim from a project root:

```bash
nvim .
```

clangd works best when the project exports `compile_commands.json`:

```bash
cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
```

Keep build, compiler, clangd, and Neovim in the same Linux environment. The
primary build and test workflow uses terminal commands or Overseer tasks; DAP
is intentionally not configured.

## Primary Keys

`<leader>` 是 `Space`。按下后稍停会在编辑器正下方显示全宽 WhichKey。

### 记忆规则

- `f` = file/find：第二个字母说明查什么，例如 `ff` 找 file、`fg` 做 grep、`fz` 进 zoxide。
- `t` = terminal：`tt` 是常规底部 terminal，`tf` 的 `f` = float。
- `r` = run：运行 Task；`b` = build，`t` = test，`s` = shell。
- `p` = problems，`c` = code/LSP，`b` = buffer，`j` = jump。
- `w` = window；进入窗口分类后，`|` 看起来是左右分隔线，`-` 看起来是上下分隔线。
- `[` 表示上一个，`]` 表示下一个；后缀说明对象：`b` Buffer、`d` Diagnostic、`h` Git hunk、`q` Quickfix、`t` TODO。

### 文件、Buffer 与窗口

| 按键 | 含义 |
| --- | --- |
| `<leader>ff` / `<leader>fg` | 查找项目 file / grep 项目文本 |
| `<leader>fe` / `<leader>fy` | 打开 Explorer / Yazi |
| `<leader>fz` / `<leader>fr` | Zoxide 目录跳转 / 项目搜索替换 |
| `<leader>fs` / `<leader>fS` | 当前文件 / 整个项目的 LSP Symbol |
| `<leader>bb` | 浏览 Buffer |
| `<leader>bd` / `<leader>bo` / `<leader>ba` | 关闭当前 / 其他 / 全部 Buffer |
| `[b` / `]b` | 上一个 / 下一个 Buffer |
| `Ctrl+H/J/K/L` | 转到左 / 下 / 上 / 右窗口 |
| `<leader>w|` / `<leader>w-` | 左右 / 上下分屏 |
| `Ctrl+方向键` | 按方向增减当前窗口宽度或高度，每次 2 行/列 |
| `Ctrl+W =` | 均分所有窗口 |
| `<leader>wd` | 关闭当前窗口 |

### Terminal 与 Task

| 按键 | 含义 |
| --- | --- |
| `<leader>tt` / `<leader>tf` | 切换底部 / 悬浮 Terminal |
| `Ctrl+Q` | 从 Terminal 输入模式回到普通模式 |
| `<leader>rr` | 选择并运行任意 Task |
| `<leader>rb` / `<leader>rt` | 选择并运行 Build / Test Task |
| `<leader>rs` | 输入并运行临时 Shell Task |
| `<leader>rl` / `<leader>ra` | 切换 Task 列表 / 操作当前 Task |

### C++、LSP 与导航

| 按键 | 含义 |
| --- | --- |
| `gd` / `gD` | 跳转到定义 / 声明 |
| `gy` / `gI` | 跳转到类型定义 / 实现 |
| `gr` | 查找引用 |
| `K` / `gK` | 查看 LSP 文档 / 函数签名 |
| `<leader>ca` / `<leader>cr` | Code Action / 重命名 Symbol |
| `<leader>cf` | 格式化文件或选区 |
| `<leader>ch` | clangd 切换 Source/Header |
| `<leader>ci` / `<leader>co` | Incoming / Outgoing Calls |
| `<leader>uh` | 切换 LSP 内联提示 |
| `<leader>jj` / `<leader>jl` / `<leader>jt` | Flash 跳转 / 跳到行 / Treesitter 选择 |
| `za` / `zo` / `zc` | 切换 / 打开 / 关闭当前折叠 |
| `zR` / `zM` | 打开 / 关闭全部折叠 |

### Problems、Git 与其他

| 按键 | 含义 |
| --- | --- |
| `[d` / `]d` | 上一个 / 下一个 Diagnostic |
| `<leader>pd` | 当前行 Problem 详情 |
| `<leader>pp` / `<leader>pb` | 项目 / 当前 Buffer Problems 面板 |
| `[q` / `]q` | 上一个 / 下一个 Quickfix 项 |
| `[t` / `]t` | 上一个 / 下一个 TODO/FIXME |
| `[h` / `]h` | 上一个 / 下一个 Git hunk |
| `<leader>ghp` / `<leader>gg` | 预览 Git hunk / 打开 Lazygit |
| `Ctrl+S` | 保存文件 |
| `Ctrl+/` | 切换当前行或选区注释 |
| `<leader>um` / `<leader>cp` | Markdown 终端渲染 / 浏览器预览 |
| `<leader>qs` / `<leader>qq` | 恢复项目 Session / 退出全部 |
| `<leader>l` / `<leader>cm` | Lazy 插件管理 / Mason 工具管理 |
| `<leader>?` | 查看当前 Buffer 的快捷键 |
| `p` / `Ctrl+Shift+V` | 从系统剪贴板粘贴 |
| Neovide `Ctrl+V` | 从系统剪贴板粘贴 |

Vim 原生的 `s`、`S`、`H` 和 `L` 行为保留。Flash 使用单独的 `<leader>j`
前缀；OpenCode、NVRH 和 DAP 均未同步。Windows 下打开支持的图片时会启动
ImageGlass Classic 并关闭二进制 Buffer。CMake 语言支持和 cmake-tools 命令仍然
可用，但暂时不给低频 CMake 命令分配主快捷键。

The Linux package option installs: a C/C++ compiler, clangd/clang tools, CMake,
Ninja, Git, tmux, ripgrep, fd, Node/npm, Python/pip, curl, tar, and unzip. Node
and Python are needed by the JSON, YAML, and CMake tooling installed through
Mason. Markdown lint/TOC tools are omitted to avoid requiring Node 22 on every
remote distribution.

## Completion

Completion uses Blink's `super-tab` preset. `Tab` / `Shift+Tab` moves forward /
backward through completion candidates and snippet positions. `Enter` keeps its
normal newline behavior and does not accidentally accept the selected item;
`Ctrl+Space` opens completion explicitly.

## SSH Clipboard

The configuration uses `clipboard=unnamedplus`, so normal yanks and puts use
the system clipboard. Verify the remote clipboard path with:

```vim
:checkhealth vim.provider
```

Inside tmux, also verify:

```bash
tmux show -s set-clipboard
tmux info | grep 'Ms:'
```

The expected values are `on` and a non-missing `Ms` capability.
