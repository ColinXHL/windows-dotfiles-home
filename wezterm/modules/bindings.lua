local wezterm = require("wezterm")
local act = wezterm.action
local cmdpicker = wezterm.plugin.require("https://github.com/abidibo/wezterm-cmdpicker")

local M = {}

function M.apply_to_config(config)
	config.leader = {
		key = "a",
		mods = "CTRL",
		timeout_milliseconds = 1500,
	}

	config.keys = {
		{
			key = "c",
			mods = "CTRL|SHIFT",
			action = act.CopyTo("Clipboard"),
			desc = "复制到系统剪贴板",
		},
		{
			key = "v",
			mods = "CTRL|SHIFT",
			action = act.PasteFrom("Clipboard"),
			desc = "粘贴系统剪贴板",
		},
		{
			key = "t",
			mods = "CTRL|SHIFT",
			action = act.SpawnTab("CurrentPaneDomain"),
			desc = "新建标签",
		},
		{
			key = "d",
			mods = "LEADER",
			action = act.CloseCurrentPane({ confirm = true }),
			desc = "关闭当前分屏",
		},
		{
			key = "phys:Backslash",
			mods = "LEADER|SHIFT",
			action = act.SplitHorizontal({
				domain = "CurrentPaneDomain",
			}),
			desc = "左右分屏",
		},
		{
			key = "-",
			mods = "LEADER",
			action = act.SplitVertical({
				domain = "CurrentPaneDomain",
			}),
			desc = "上下分屏",
		},
		{
			key = "h",
			mods = "LEADER",
			action = act.ActivatePaneDirection("Left"),
			desc = "聚焦左侧分屏",
		},
		{
			key = "j",
			mods = "LEADER",
			action = act.ActivatePaneDirection("Down"),
			desc = "聚焦下方分屏",
		},
		{
			key = "k",
			mods = "LEADER",
			action = act.ActivatePaneDirection("Up"),
			desc = "聚焦上方分屏",
		},
		{
			key = "l",
			mods = "LEADER",
			action = act.ActivatePaneDirection("Right"),
			desc = "聚焦右侧分屏",
		},
		{
			key = "r",
			mods = "LEADER",
			action = act.ActivateKeyTable({
				name = "resize_pane",
				one_shot = false,
			}),
			desc = "进入分屏调整模式",
		},
		{
			key = "z",
			mods = "LEADER",
			action = act.TogglePaneZoomState,
			desc = "切换分屏缩放",
		},
		{
			key = "a",
			mods = "LEADER",
			action = act.SendKey({ key = "a", mods = "CTRL" }),
			desc = "发送 Ctrl+A",
		},
		{
			key = "f",
			mods = "CTRL|SHIFT",
			action = act.Search("CurrentSelectionOrEmptyString"),
			desc = "搜索终端历史",
		},
		{
			key = "s",
			mods = "LEADER",
			action = act.QuickSelectArgs({
				action = act.Multiple({
					act.CopyTo("Clipboard"),
					act.ClearSelection,
				}),
			}),
			desc = "快速选择并复制文本",
		},
		{
			key = "[",
			mods = "LEADER",
			action = act.ActivateCopyMode,
			desc = "进入 Vim Copy Mode",
		},
		{
			key = "p",
			mods = "CTRL|SHIFT",
			action = act.ActivateCommandPalette,
			desc = "打开 WezTerm 命令面板",
		},
		{
			key = "r",
			mods = "CTRL|SHIFT",
			action = act.ReloadConfiguration,
			desc = "重新加载配置",
		},
		{
			key = "Enter",
			mods = "LEADER",
			action = act.ToggleFullScreen,
			desc = "切换全屏",
		},
		{
			key = "Enter",
			mods = "ALT",
			action = act.DisableDefaultAssignment,
			desc = "将 Alt+Enter 交给终端应用",
		},
	}

	local exit_copy_mode = act.Multiple({
		act.CopyMode("ClearPattern"),
		act.CopyMode("ClearSelectionMode"),
		act.ScrollToBottom,
		act.CopyMode("Close"),
	})

	local copy_and_exit_copy_mode = act.Multiple({
		act.CopyTo("ClipboardAndPrimarySelection"),
		act.CopyMode("ClearPattern"),
		act.CopyMode("ClearSelectionMode"),
		act.ScrollToBottom,
		act.CopyMode("Close"),
	})

	local cancel_search_mode = act.Multiple({
		act.CopyMode("ClearPattern"),
		act.CopyMode("ClearSelectionMode"),
		act.CopyMode("AcceptPattern"),
	})

	config.key_tables = {
		resize_pane = {
			{ key = "h", action = act.AdjustPaneSize({ "Left", 2 }) },
			{ key = "j", action = act.AdjustPaneSize({ "Down", 2 }) },
			{ key = "k", action = act.AdjustPaneSize({ "Up", 2 }) },
			{ key = "l", action = act.AdjustPaneSize({ "Right", 2 }) },
			{ key = "Escape", action = "PopKeyTable" },
			{ key = "q", action = "PopKeyTable" },
		},
		copy_mode = wezterm.gui.default_key_tables().copy_mode,
		search_mode = {
			{ key = "Enter", action = act.CopyMode("AcceptPattern") },
			{ key = "Escape", action = cancel_search_mode },
			{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
			{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
			{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
			{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
			{ key = "PageUp", action = act.CopyMode("PriorMatchPage") },
			{ key = "PageDown", action = act.CopyMode("NextMatchPage") },
			{ key = "UpArrow", action = act.CopyMode("PriorMatch") },
			{ key = "DownArrow", action = act.CopyMode("NextMatch") },
		},
	}

	table.insert(config.key_tables.copy_mode, {
		key = "/",
		action = act.Search("CurrentSelectionOrEmptyString"),
	})
	table.insert(config.key_tables.copy_mode, { key = "n", action = act.CopyMode("NextMatch") })
	table.insert(config.key_tables.copy_mode, { key = "p", action = act.CopyMode("PriorMatch") })
	table.insert(config.key_tables.copy_mode, { key = "Escape", action = exit_copy_mode })
	table.insert(config.key_tables.copy_mode, { key = "q", action = exit_copy_mode })
	table.insert(config.key_tables.copy_mode, { key = "c", mods = "CTRL", action = exit_copy_mode })
	table.insert(config.key_tables.copy_mode, { key = "g", mods = "CTRL", action = exit_copy_mode })
	table.insert(config.key_tables.copy_mode, { key = "y", action = copy_and_exit_copy_mode })

	for i = 1, 9 do
		table.insert(config.keys, {
			key = tostring(i),
			mods = "LEADER",
			action = act.ActivateTab(i - 1),
			desc = "切换到标签 " .. i,
		})
	end

	cmdpicker.add_keys(config.keys)
	cmdpicker.apply_to_config(config, {
		key = "phys:Slash",
		mods = "LEADER|SHIFT",
		title = "快捷键",
		include_defaults = false,
		fuzzy_description = "搜索快捷键: ",
	})
end

return M
