-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.scrolloff = 8
vim.opt.number = true
vim.opt.relativenumber = true

-- Keep normal yanks and puts synchronized with the system clipboard.
vim.opt.clipboard = "unnamedplus"

local function map_system_paste(lhs)
  vim.keymap.set("n", lhs, '"+p', { desc = "Paste from System Clipboard" })
  vim.keymap.set("x", lhs, '"+P', { desc = "Paste from System Clipboard" })
  vim.keymap.set({ "i", "c" }, lhs, "<C-r>+", { desc = "Paste from System Clipboard" })
end

-- Terminal emulators often handle this themselves; keep the Neovim mapping as
-- a fallback for terminals that forward the key sequence.
map_system_paste("<C-S-v>")

-- 设置自动读取外部改变
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

if vim.g.neovide then
  if vim.fn.argc(-1) == 0 then
    vim.fn.chdir(vim.fn.expand("~"))
  end

  vim.opt.linespace = 2

  vim.g.neovide_input_ime = false
  local ime_group = vim.api.nvim_create_augroup("neovide_ime", { clear = true })
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = ime_group,
    callback = function()
      vim.g.neovide_input_ime = true
    end,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = ime_group,
    callback = function()
      vim.g.neovide_input_ime = false
    end,
  })

  vim.g.neovide_scale_factor = 1.0
  vim.g.neovide_pixel_geometry = "RGBH"

  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_top = 8
  vim.g.neovide_padding_bottom = 8

  vim.g.neovide_theme = "dark"
  vim.g.neovide_title_background_color = "#11111b"
  vim.g.neovide_title_text_color = "#cdd6f4"
  vim.g.neovide_corner_preference = "round"

  -- Keep glyphs opaque and apply transparency only to the Normal background.
  vim.g.neovide_opacity = 1.0
  vim.g.neovide_normal_opacity = 0.75

  vim.g.neovide_floating_corner_radius = 0.12
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_hide_mouse_when_typing = true

  map_system_paste("<C-v>")
end
