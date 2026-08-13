local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
	local nf = wezterm.nerdfonts

	config.font = wezterm.font_with_fallback({
		{ family = "0xProto", weight = "Regular" },
		{ family = "JetBrainsMono Nerd Font Mono", weight = "Regular" },
		{ family = "Maple Mono Normal NF CN", weight = "Regular" },
		"Segoe UI Emoji",
	})
	-- 本机当前为 125% 缩放（120 DPI），12pt 对应 20px。不要覆盖 config.dpi：Windows
	-- 会向 WezTerm 报告窗口所在显示器的 DPI，并在跨屏时自动调整。
	config.font_size = 12
	-- Retro Tab Bar 共用正文的单元格高度；额外行高避免中文贴顶或被裁切。
	config.line_height = 1.2
	-- Match Neovide's full hinting and horizontal RGB subpixel antialiasing.
	config.freetype_load_target = "HorizontalLcd"
	config.freetype_render_target = "HorizontalLcd"

	-- 匹配当前 2560x1440、144Hz 主显示器。
	config.max_fps = 144
	config.animation_fps = 144

	config.front_end = "OpenGL"

	config.webgpu_power_preference = "HighPerformance"

	-- 不喜欢连字时取消下面代码的注释。
	-- config.harfbuzz_features = {
	--   "calt=0",
	--   "clig=0",
	--   "liga=0",
	-- }

	config.color_scheme = "Catppuccin Mocha"
	-- Let the live desktop wallpaper show through the terminal. Keep the system
	-- backdrop disabled so the wallpaper stays clear instead of becoming Acrylic.
	config.window_background_opacity = 0.58
	config.text_background_opacity = 0.82
	config.win32_system_backdrop = "Disable"

	config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
	config.window_padding = {
		left = 10,
		right = 10,
		top = 8,
		bottom = 8,
	}

	config.initial_cols = 140
	config.initial_rows = 40
	config.adjust_window_size_when_changing_font_size = false
	config.scrollback_lines = 20000
	config.audible_bell = "Disabled"
	config.default_cursor_style = "BlinkingBar"

	config.use_fancy_tab_bar = false
	config.show_new_tab_button_in_tab_bar = false
	config.tab_max_width = 28
	config.switch_to_last_active_tab_when_closing_tab = true
	config.tab_bar_style = {
		window_hide = " " .. nf.cod_chrome_minimize .. " ",
		window_hide_hover = " " .. nf.cod_chrome_minimize .. " ",
		window_maximize = " " .. nf.cod_chrome_maximize .. " ",
		window_maximize_hover = " " .. nf.cod_chrome_maximize .. " ",
		window_close = " " .. nf.cod_chrome_close .. " ",
		window_close_hover = " " .. nf.cod_chrome_close .. " ",
	}

	config.inactive_pane_hsb = {
		saturation = 0.85,
		brightness = 0.72,
	}

	config.use_cap_height_to_scale_fallback_fonts = true
end

return M
