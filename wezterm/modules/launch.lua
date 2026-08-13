local wezterm = require("wezterm")

local M = {}

wezterm.on("gui-startup", function(cmd)
	local _, _, mux_window = wezterm.mux.spawn_window(cmd or {})
	local window = mux_window:gui_window()
	local screen = wezterm.gui.screens().active
	local dimensions = window:get_dimensions()

	window:set_position(
		math.floor(screen.x + (screen.width - dimensions.pixel_width) / 2),
		math.floor(screen.y + (screen.height - dimensions.pixel_height) / 2)
	)
end)

function M.apply_to_config(config)
	-- WezTerm 启动时直接运行 Nushell，并从用户主目录启动。
	config.default_prog = { "nu.exe" }
	config.default_cwd = wezterm.home_dir

	config.launch_menu = {
		{
			label = "Nushell",
			args = { "nu.exe" },
		},
		{
			label = "Windows PowerShell",
			args = { "powershell.exe", "-NoLogo" },
		},
		{
			label = "Command Prompt",
			args = { "cmd.exe" },
		},
		{
			label = "PowerShell 7",
			args = { "pwsh.exe", "-NoLogo" },
		},
	}
end

return M
