# Astral Teal

这是为当前 Windows 桌面设计的深青星环 Dream Skin。源文件和可导入 ZIP 都保存在 dotfiles 中；`background.png` 是基于用户提供插画生成的干净 16:9 背景，已经移除外部白边与右上角文字。

视觉策略：

- 沿用 Dream Skin 内置 Gothic 主题的原生层级，让背景明暗与面板表面承担主要分区。
- 以 `#00868d` 为主色，只给状态、侧栏分隔线和交互反馈少量深青点缀。
- 输入框取消额外青色硬描边与光晕，恢复为柔和的原生深色浮层。
- 任务页使用 `ambient` 背景模式，人物保持在中右侧，左侧为侧栏和导航保留暗色安全区。

Neovide 使用单独配置的字体回退链：图标子集、0xProto 西文、Maple Mono NF CN 中文、Emoji。Dream Skin 的 Safe CSS 只允许通用字体族，不能安全引用这些本机字体名，因此本主题不绕过校验强制修改 Codex 字体。

## 构建与导入

运行：

```powershell
pwsh -NoProfile -File "$HOME\windows-dotfiles\codex-dream-skin\build-theme.ps1"
```

生成的 `dist/astral-teal.zip` 可从 Dream Skin 托盘菜单的“导入主题 ZIP…”导入。导入只加入主题库，不会自动应用。
