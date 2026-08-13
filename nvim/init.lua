-- Load process environment before LazyVim starts Git or Treesitter.
require("config.environment")

-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.fn.has("win32") == 1 then
  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = {
      "*.avif",
      "*.bmp",
      "*.gif",
      "*.heic",
      "*.ico",
      "*.jpeg",
      "*.jpg",
      "*.jxl",
      "*.png",
      "*.svg",
      "*.tif",
      "*.tiff",
      "*.webp",
    },
    callback = function(args)
      local viewer = (vim.env.ProgramFiles or "C:\\Program Files") .. "\\ImageGlass\\ImageGlass.exe"
      if not vim.uv.fs_stat(viewer) then
        vim.notify("ImageGlass is not installed: " .. viewer, vim.log.levels.ERROR)
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) then
            vim.api.nvim_buf_delete(args.buf, { force = true })
          end
        end)
        return
      end

      vim.system({ viewer, vim.fn.fnamemodify(args.file, ":p") }, { detach = true })
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(args.buf) then
          return
        end
        if Snacks then
          Snacks.bufdelete({ buf = args.buf, force = true })
        else
          vim.api.nvim_buf_delete(args.buf, { force = true })
        end
      end)
    end,
  })
end

require("config.lazy")
