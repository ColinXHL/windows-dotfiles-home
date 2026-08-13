# Nilesoft Shell Config

一套面向 Windows 11 中文环境的 [Nilesoft Shell](https://nilesoft.org/) 配置，重点是保持一级菜单简洁、按上下文显示工具，并将低频项目集中到“更多操作”。

## 功能

- 按文件类型显示 Code、Neovide、记事本、打印和 PeaZip 操作。
- 保留 Windows 原生“打开”和“打开方式”，不修改默认文件关联。
- 为压缩文件提供 PeaZip“智能解压到此处”。
- 为文件夹提供终端、Code、Neovide 和 PeaZip 一级入口。
- 整理桌面及文件夹空白处菜单，支持 Everything 缺失时稳定降级。
- 清理 Git、网盘、WPS 等不需要的第三方菜单项。
- 提供中文任务栏空白处菜单，包括任务管理器、显示桌面、窗口排列和系统设置。
- 使用亚克力主题，并跟随系统深浅色模式。

## 环境

- Windows 11
- Nilesoft Shell 1.9.18
- 固定使用中文系统菜单

以下应用均为可选项。配置会通过 `path.exists(...)` 判断是否显示：

| 应用 | 默认路径 |
| --- | --- |
| Visual Studio Code | `%LocalAppData%\Programs\Microsoft VS Code\Code.exe` |
| Neovide | `%ProgramFiles%\Neovide\neovide.exe` |
| Everything | `%ProgramFiles%\Everything\Everything.exe` |
| PeaZip | `%ProgramFiles%\PeaZip\PEAZIP.EXE` |

路径集中定义在 [`imports/config.nss`](imports/config.nss)。应用安装位置不同时，只需修改该文件。

## 安装

在管理员 PowerShell 中运行统一安装器：

```powershell
pwsh -NoProfile -File "$HOME\windows-dotfiles\install.ps1"
```

安装器会为 `shell.nss` 和仓库维护的全部 `imports/*.nss` 创建文件级符号链接，然后重启 Nilesoft Shell。不会链接整个 `imports` 目录，因此 Nilesoft 自带的其他模块会原样保留。首次替换的文件会以带时间戳的 `.bak` 名称备份。

`Program Files` 目录需要管理员权限；只安装其他用户级配置时可添加 `-SkipNilesoft`。如果 Nilesoft 更新覆盖了链接，重新运行安装器即可恢复。配置错误会记录在：

```text
C:\Program Files\Nilesoft Shell\shell.log
```

## 菜单结构

### 可编辑文本

```text
打开
通过 Code 打开
通过 Neovide 打开
在记事本中编辑
打开方式
----------------
文件操作
更多操作
属性
```

### 文件夹

文件夹一级菜单包含原生“打开”和“在终端中打开”；根据相应可执行文件
是否存在，还会显示“通过 Code 打开”、PeaZip 和“通过 Neovide 打开”。其余一级项目包括剪切、复制、复制文件
地址、删除、重命名、“更多操作”和“属性”。

### 任务栏空白处

```text
任务管理器
显示桌面
窗口排列
任务栏设置
系统设置
```

按住 `Shift` 时还会显示“重新启动资源管理器”。

## 模块

| 文件 | 用途 |
| --- | --- |
| `shell.nss` | 主入口和导入顺序 |
| `imports/config.nss` | 应用路径与扩展名分组 |
| `imports/theme.nss` | 主题配置 |
| `imports/images.nss` | 图标资源 |
| `imports/customize.nss` | 文件和文件夹菜单整理 |
| `imports/background.nss` | 桌面与文件夹空白处菜单 |
| `imports/code.nss` | VS Code 操作 |
| `imports/nvim.nss` | Neovide 操作 |
| `imports/peazip.nss` | PeaZip 智能解压 |
| `imports/taskbar.nss` | 任务栏空白处菜单 |

## 重载技巧

- `Ctrl + 右键`：重新加载 `shell.nss`。
- `右键 + 左键`：重新加载配置。
- 修改后检查 `shell.log`，确认没有新增错误。

## 注意

- 配置不会修改 Windows 默认应用关联。
- 菜单排序针对 Nilesoft Shell 1.9.18 和中文环境设计。
- 安装或卸载可选应用后，重新加载配置即可更新菜单项。
