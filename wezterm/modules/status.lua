local wezterm = require("wezterm")

local M = {}
local opencode_font = wezterm.font_with_fallback({
	{ family = "Courier Prime", weight = "Regular" },
	"0xProto Nerd Font Mono",
	{ family = "Noto Serif SC", weight = "Medium", scale = 1.02 },
	"Segoe UI Emoji",
})

local full_bleed_processes = {
	["nvim"] = true,
	["nvim.exe"] = true,
	["opencode"] = true,
	["opencode.exe"] = true,
}

local active_apps = {}
local missed_app_checks = {}
local opencode_font_windows = {}

local function process_name_from_info(info)
	local path = info.executable
	if not path or path == "" then
		path = info.name or ""
	end
	return (path:match("([^/\\]+)$") or ""):lower()
end

local function find_active_app(pane)
	local info = pane:get_foreground_process_info()
	if not info then
		return nil, false
	end

	local seen = {}
	for _ = 1, 8 do
		local process_name = process_name_from_info(info)
		if full_bleed_processes[process_name] then
			return process_name, true
		end

		local parent_pid = tonumber(info.ppid)
		if not parent_pid or parent_pid <= 0 or seen[parent_pid] then
			break
		end
		seen[parent_pid] = true
		info = wezterm.procinfo.get_info_for_pid(parent_pid)
		if not info then
			break
		end
	end

	return nil, true
end

local function update_window_overrides(window, pane)
	local process_path = pane:get_foreground_process_name() or ""
	local process_name = (process_path:match("([^/\\]+)$") or ""):lower()
	local active_app = find_active_app(pane)
	if active_app then
		process_name = active_app
	else
		local pane_title = (pane:get_title() or ""):lower()
		if pane_title:find("opencode", 1, true) or pane_title:match("^oc%s*|") then
			process_name = "opencode"
		elseif pane_title:find("nvim", 1, true) then
			process_name = "nvim"
		end
	end

	local pane_id = pane:pane_id()
	if full_bleed_processes[process_name] then
		active_apps[pane_id] = process_name
		missed_app_checks[pane_id] = 0
	elseif active_apps[pane_id] and (missed_app_checks[pane_id] or 0) < 3 then
		missed_app_checks[pane_id] = (missed_app_checks[pane_id] or 0) + 1
		process_name = active_apps[pane_id]
	else
		active_apps[pane_id] = nil
		missed_app_checks[pane_id] = nil
	end

	local needs_full_bleed = full_bleed_processes[process_name] == true
	local needs_opencode_font = process_name == "opencode" or process_name == "opencode.exe"
	local window_id = window:window_id()
	local overrides = window:get_config_overrides() or {}
	local padding = overrides.window_padding
	local has_zero_padding = padding
		and padding.left == 0
		and padding.right == 0
		and padding.top == 0
		and padding.bottom == 0
	local has_expected_padding = needs_full_bleed == (has_zero_padding == true)
	local has_expected_font = overrides.font == nil and overrides.font_size == nil and overrides.line_height == nil
	if needs_opencode_font then
		has_expected_font = opencode_font_windows[window_id]
			and overrides.font ~= nil
			and overrides.font_size == 12.5
			and overrides.line_height == 1.2
	end
	if
		has_expected_padding
		and has_expected_font
		and overrides.window_background_opacity == nil
		and overrides.text_background_opacity == nil
		and overrides.colors == nil
		and overrides.background == nil
	then
		return
	end

	overrides.window_padding = needs_full_bleed and {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	} or nil
	overrides.font = needs_opencode_font and opencode_font or nil
	overrides.font_size = needs_opencode_font and 12.5 or nil
	overrides.line_height = needs_opencode_font and 1.2 or nil
	opencode_font_windows[window_id] = needs_opencode_font and true or nil
	overrides.window_background_opacity = nil
	overrides.text_background_opacity = nil
	overrides.colors = nil
	overrides.background = nil
	window:set_config_overrides(overrides)
end

function M.apply_to_config(_)
	wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, _hover, max_width)
		local process_name = active_apps[tab.active_pane.pane_id]
		if process_name == "opencode" or process_name == "opencode.exe" then
			local pane_title = tab.active_pane.title or ""
			local title = pane_title:match("^OC") and pane_title or "OpenCode"
			return "  " .. wezterm.truncate_right(title, math.max(max_width - 4, 1)) .. "  "
		end
	end)

	wezterm.on("update-status", function(window, pane)
		update_window_overrides(window, pane)

		if window:leader_is_active() then
			window:set_right_status(" LEADER  ? commands ")
			return
		end

		local key_table = window:active_key_table()
		if key_table == "resize_pane" then
			window:set_right_status(" RESIZE  hjkl adjust  Esc/q exit ")
			return
		end
		if key_table == "copy_mode" then
			window:set_right_status(" COPY  / search  n/p matches  v select  y copy  Esc/q exit ")
			return
		end
		if key_table == "search_mode" then
			window:set_right_status(" SEARCH  type query  Enter accept  Esc cancel ")
			return
		end
		window:set_right_status(key_table and (" " .. key_table .. " ") or "")
	end)
end

return M
