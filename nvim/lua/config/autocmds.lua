-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LazyVim enables spell checking for Markdown in its wrap_spell autocmd.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- Floating pickers and dashboards can disable their window-local number column.
-- Restore the normal editing view when the window is reused for a file.
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  group = vim.api.nvim_create_augroup("restore_file_line_numbers", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.bo[args.buf].filetype == "bigfile" then
      return
    end

    vim.wo.number = true
    vim.wo.relativenumber = true
    vim.wo.statuscolumn = vim.go.statuscolumn
  end,
})
