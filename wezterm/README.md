# WezTerm Config

一套面向 Windows 的模块化 WezTerm 配置，使用 Nushell、Retro Tab Bar 和 Vim/tmux 风格快捷键。

当前配置在 WezTerm Nightly `20260716-195552-76b606ec` 上验证通过。

## 特性

- Nushell 作为默认 Shell
- Catppuccin Mocha 配色与低对比度纵向视差背景
- 12pt 字体栈：`JetBrainsMono Nerd Icons` -> `0xProto Nerd Font Mono` -> `Noto Serif SC Medium` -> `Segoe UI Emoji`
- `Ctrl+A` Leader 和模式化 Pane 操作
- Vim 风格 Copy/Search Mode
- Quick Select、鼠标选择和右键智能复制/粘贴
- 可搜索的自定义快捷键浮层
- 按职责拆分的 Lua 模块

## 依赖

- Windows 10 或 Windows 11
- [WezTerm](https://wezterm.org/installation.html)
- [Nushell](https://www.nushell.sh/)
- [0xProto Nerd Font Mono](https://www.nerdfonts.com/font-downloads)、`JetBrains Mono`、`Noto Serif SC` 和 `Courier Prime`
- PowerShell 7：运行仓库根目录安装器时必需；手工安装时仅 Launcher 中的 PowerShell 7 条目需要

`Segoe UI Emoji` 通常随 Windows 提供。首次引用
插件且本地尚无缓存时需要访问 GitHub；WezTerm 会克隆并缓存
[wezterm-cmdpicker](https://github.com/abidibo/wezterm-cmdpicker)。插件 URL
未固定到特定提交，已缓存副本不会自动更新。当前浮层只列出自定义
`config.keys`，不包含 WezTerm 默认快捷键或 Key Table。

## 安装

在没有 `--config-file`、`WEZTERM_CONFIG_FILE`、便携模式配置或其他更高
优先级配置时，WezTerm 会从 `$HOME\.config\wezterm\wezterm.lua`（通常即
`%USERPROFILE%\.config\wezterm\wezterm.lua`）加载这套配置。

在 PowerShell 7 中从仓库根目录运行 `.\install.ps1`。这是整个 dotfiles
仓库的安装器，不只处理 WezTerm。它会分别为 `wezterm.lua`、当前的
`modules\*.lua` 和 `assets` 中的文件创建符号链接；Windows 必须允许当前
用户创建符号链接，例如启用 Developer Mode 或使用提升权限。

若某个目标已存在且不是指向同一源文件的符号链接，安装器会先将其
移动为 `<原路径>.pre-dotfiles-yyyyMMdd-HHmmss.bak`。同目标的现有符号
链接保持不变；安装器不会清理已经从仓库删除的旧 WezTerm 模块或资源链接。
主配置及通过 `require` 加载的模块由 WezTerm 监视，修改后通常会自动
重载。

## 目录结构

```text
~/.config/wezterm/
|-- wezterm.lua
|-- assets/
|   `-- tokyo-night-parallax.png  # 保留备用，当前不加载
`-- modules/
    |-- launch.lua
    |-- appearance.lua
    |-- mouse.lua
    |-- bindings.lua
    `-- status.lua
```

仓库中的 `wezterm/README.md` 仅作为文档保留，安装器不会将其链接到配置
目录。

| 文件 | 职责 |
| --- | --- |
| `wezterm.lua` | 创建 Config，并显式控制模块加载顺序 |
| `assets/tokyo-night-parallax.png` | 保留的旧视差背景素材，当前配置不加载 |
| `modules/launch.lua` | 默认 Shell、工作目录、Launcher 菜单，以及 GUI 启动窗口在活动显示器上的居中 |
| `modules/appearance.lua` | 字体、配色、窗口、标签栏和 Pane 外观 |
| `modules/mouse.lua` | 鼠标选择、复制、粘贴和链接操作 |
| `modules/bindings.lua` | Leader、快捷键、Key Table 和 cmdpicker 插件 |
| `modules/status.lua` | Leader/Key Table 状态提示，以及 Neovim/OpenCode 的进程感知窗口边距 |

每个模块都遵循 WezTerm 推荐的 `module.apply_to_config(config)` 约定。入口文件显式加载模块，不会自动执行目录中的其他 Lua 文件。

## Shell 与外观

默认程序为 PATH 中的 `nu.exe`，默认工作目录为用户主目录。Launcher 提供
Nushell、Windows PowerShell、Command Prompt 和 PowerShell 7。正常 GUI
启动时，配置会创建窗口并将其居中到活动显示器。

最大渲染与动画帧率为 144 FPS，以匹配当前 2560x1440、144Hz 主显示器。
字体使用 12pt；当前 125% 缩放（120 DPI）下对应 20px，并使用横向 RGB 子像素抗锯齿。
配置不覆盖 DPI，由 Windows 和 WezTerm 在窗口跨显示器时自动调整。主题为
Catppuccin Mocha，窗口背景不透明度
为 0.58，文本单元格背景不透明度为 0.82，并禁用 Windows 系统背景材质，
让 Wallpaper Engine 的实时桌面清晰透入。当前不加载额外背景图片。

窗口初始为 140x40 单元格，边距为左右 10、上下 8，回滚区为 20,000 行，
响铃关闭，光标为闪烁竖线。非活动 Pane 会降低饱和度和亮度。Retro Tab
Bar 不显示新建按钮，标签最大宽度为 28；关闭当前标签后切换到最近使用
的标签，窗口按钮集成在标签栏中。

## 状态与进程行为

右侧状态栏优先显示 Leader、Resize、Copy 或 Search Mode 的操作提示；
其他活动 Key Table 显示其名称，没有活动模式时清空状态。当前台进程的
basename 为 `nvim`、`nvim.exe`、`opencode` 或 `opencode.exe`，或 Pane
标题不区分大小写包含 `nvim` 或 `opencode` 时，窗口边距变为 0；检测暂时
丢失时最多保留 3 次状态更新，随后恢复基础边距。该逻辑也会清除窗口级
背景、颜色和透明度覆盖，以恢复 `appearance.lua` 中的基础外观。

## 快捷键

Leader 为 `Ctrl+A`，超时为 1500ms。

| 快捷键 | 操作 |
| --- | --- |
| `Leader+a` | 向终端发送原始 `Ctrl+A` |
| `Leader+Shift+phys:Slash`（美式布局显示为 `Leader+?`） | 打开只含自定义快捷键的搜索浮层 |
| `Leader+Shift+phys:Backslash`（美式布局显示为 `Leader+\|`） | 左右分屏 |
| `Leader+-` | 上下分屏 |
| `Leader+d` | 请求确认后关闭当前 Pane |
| `Leader+h/j/k/l` | 切换 Pane 焦点 |
| `Leader+r` | 进入 Pane 尺寸调整模式 |
| `Leader+z` | 切换 Pane Zoom |
| `Leader+s` | Quick Select，复制到系统剪贴板并清除选区 |
| `Leader+[` | 进入 Vim Copy Mode |
| `Leader+1..9` | 切换到对应 Tab |
| `Ctrl+Shift+T` | 新建 Tab |
| `Ctrl+Shift+C` | 复制选区到系统剪贴板 |
| `Ctrl+Shift+V` | 从系统剪贴板粘贴 |
| `Ctrl+Shift+F` | 搜索终端历史，并使用当前选区作为初始查询 |
| `Ctrl+Shift+P` | 打开命令面板 |
| `Ctrl+Shift+R` | 重新加载配置 |
| `Leader+Enter` | 切换全屏 |
| `Alt+Enter` | 禁用 WezTerm 默认全屏绑定，将按键交给终端应用 |

Pane 尺寸调整模式使用 `h/j/k/l` 每次向对应方向调整 2 个单元，使用
`Esc` 或 `q` 退出。

Copy Mode 使用 `/` 进入 Search Mode；返回 Copy Mode 后使用 `n/p` 切换
匹配，`v` 开始单元格选择，`y` 复制到系统剪贴板和 Primary Selection、
清理状态、滚动到底部并退出。`Esc`、`q`、`Ctrl+C` 或 `Ctrl+G` 清理状态、
滚动到底部并退出。Search Mode 中，`Enter` 接受查询，`Esc` 清空查询、
取消选择模式并返回 Copy Mode，`Ctrl+n/p` 切换匹配，`Ctrl+r` 切换匹配
类型，`Ctrl+u` 清空查询。

## 鼠标

以下行为适用于由 WezTerm 处理鼠标事件的情况。若终端应用启用了鼠标
上报，事件通常会发送给应用；默认可按住 `Shift` 绕过应用的鼠标捕获。

| 操作 | 行为 |
| --- | --- |
| 左键拖动 | 选择文本并保留选区 |
| 双击 | 选择单词 |
| 三击 | 选择整行 |
| `Alt+左键拖动` | 块选择 |
| `Ctrl+左键单击` | 打开鼠标下的链接 |
| 右键单击（有选区） | 复制到系统剪贴板并清除选区 |
| 右键单击（无选区） | 从系统剪贴板粘贴 |

未被覆盖的 WezTerm 默认鼠标绑定仍然有效，包括 `Shift+左键` 扩展选择、
`Alt+Shift+左键` 扩展块选择、双击/三击拖动按单词/整行扩展、鼠标中键
粘贴 Primary Selection，以及 `Ctrl+Shift+左键拖动` 或 `Super+左键拖动`
移动窗口。

## 验证

检查配置和最终快捷键表：

```powershell
wezterm show-keys
```

检查字体解析：

```powershell
wezterm ls-fonts
```

检查外部程序：

```powershell
wezterm -V
nu --version
pwsh --version
```

## 自定义

- 修改默认 Shell、工作目录、Launcher 或启动窗口居中：`modules/launch.lua`
- 修改字体、主题、背景图或透明度：`modules/appearance.lua`
- 修改鼠标行为：`modules/mouse.lua`
- 修改快捷键和模式：`modules/bindings.lua`
- 修改模式状态提示或 Neovim/OpenCode 的零边距行为：`modules/status.lua`

这份配置面向 Windows：`modules/appearance.lua` 使用 Windows 背景与集成
窗口按钮设置，`modules/launch.lua` 使用 `nu.exe`、`powershell.exe`、
`cmd.exe` 和 `pwsh.exe`。在其他平台使用时至少需要调整这两个模块。
