-- Keymaps are automatically loaded on the VeryLazy event.
-- Keep the workflow compact and group commands by a memorable English prefix.

local function del(modes, lhs)
  modes = type(modes) == "table" and modes or { modes }
  for _, mode in ipairs(modes) do
    pcall(vim.keymap.del, mode, lhs)
  end
end

do
    -- Preserve native H/L motions and leave Alt combinations to GlazeWM.
    for _, lhs in ipairs({ "<S-h>", "<S-l>" }) do
      del("n", lhs)
    end
    for _, lhs in ipairs({ "<A-j>", "<A-k>" }) do
      del({ "n", "i", "v" }, lhs)
    end

    -- Remove overlapping LazyVim aliases before defining the smaller workflow.
    for _, lhs in ipairs({
      "<leader><space>",
      "<leader>/",
      "<leader>,",
      "<leader>:",
      "<leader>e",
      "<leader>E",
      "<leader>y",
      "<leader>z",
      "<leader>|",
      "<leader>-",
      "<leader>fB",
      "<leader>fb",
      "<leader>fc",
      "<leader>fe",
      "<leader>fE",
      "<leader>ff",
      "<leader>fF",
      "<leader>fg",
      "<leader>fn",
      "<leader>fp",
      "<leader>fR",
      "<leader>ft",
      "<leader>fT",
      "<leader>gD",
      "<leader>gd",
      "<leader>gB",
      "<leader>gb",
      "<leader>gf",
      "<leader>gG",
      "<leader>gi",
      "<leader>gI",
      "<leader>gl",
      "<leader>gL",
      "<leader>gp",
      "<leader>gP",
      "<leader>gs",
      "<leader>gS",
      "<leader>gY",
      '<leader>s"',
      "<leader>s/",
      "<leader>sa",
      "<leader>sb",
      "<leader>sB",
      "<leader>sc",
      "<leader>sC",
      "<leader>sd",
      "<leader>sD",
      "<leader>sg",
      "<leader>sG",
      "<leader>sh",
      "<leader>sH",
      "<leader>si",
      "<leader>sj",
      "<leader>sk",
      "<leader>sl",
      "<leader>sm",
      "<leader>sM",
      "<leader>sp",
      "<leader>sq",
      "<leader>sr",
      "<leader>sR",
      "<leader>st",
      "<leader>sT",
      "<leader>su",
      "<leader>sw",
      "<leader>sW",
    }) do
      del({ "n", "x" }, lhs)
    end

    -- Keep only the high-frequency Buffer operations.
    for _, lhs in ipairs({
      "<leader>`",
      "<leader>bb",
      "<leader>bD",
      "<leader>bi",
      "<leader>bj",
      "<leader>bl",
      "<leader>bo",
      "<leader>bp",
      "<leader>bP",
      "<leader>br",
    }) do
      del("n", lhs)
    end

    -- Diagnostics use the mnemonic <leader>p (Problems) group.
    for _, lhs in ipairs({
      "<leader>cd",
      "<leader>cs",
      "<leader>cS",
      "<leader>xl",
      "<leader>xL",
      "<leader>xq",
      "<leader>xQ",
      "<leader>xx",
      "<leader>xX",
      "<leader>xt",
      "<leader>xT",
      "[D",
      "]D",
      "[e",
      "]e",
      "[w",
      "]w",
    }) do
      del({ "n", "x" }, lhs)
    end

    -- Low-frequency UI, notification, profiler, and tab actions stay commands.
    for _, lhs in ipairs({
      "<leader>.",
      "<leader>K",
      "<leader>L",
      "<leader>S",
      "<leader>n",
      "<leader>sn",
      "<leader>sna",
      "<leader>snd",
      "<leader>snh",
      "<leader>snl",
      "<leader>snt",
      "<leader>uA",
      "<leader>ua",
      "<leader>ub",
      "<leader>uc",
      "<leader>uC",
      "<leader>ud",
      "<leader>uD",
      "<leader>uf",
      "<leader>uF",
      "<leader>ug",
      "<leader>ui",
      "<leader>uI",
      "<leader>ul",
      "<leader>uL",
      "<leader>un",
      "<leader>ur",
      "<leader>us",
      "<leader>uS",
      "<leader>uT",
      "<leader>up",
      "<leader>uw",
      "<leader>uZ",
      "<leader>uz",
      "<leader>wm",
      "<leader>dph",
      "<leader>dpp",
      "<leader><tab><tab>",
      "<leader><tab>[",
      "<leader><tab>]",
      "<leader><tab>d",
      "<leader><tab>f",
      "<leader><tab>l",
      "<leader><tab>o",
    }) do
      del("n", lhs)
    end

    for _, lhs in ipairs({ "<leader>qd", "<leader>ql", "<leader>qS" }) do
      del("n", lhs)
    end

    local map = vim.keymap.set

    map({ "i", "n", "s", "x" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "保存文件" })
    map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "打开 Lazy 插件管理器" })
    map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "打开 Mason 工具管理器" })
    map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "退出全部" })
    map("n", "<leader>qs", function()
      require("persistence").load()
    end, { desc = "恢复当前项目 Session" })
    map("n", "<leader>?", function()
      require("which-key").show({ global = false })
    end, { desc = "查看当前 Buffer 快捷键" })
    map("n", "<C-w><space>", function()
      require("which-key").show({ keys = "<c-w>", loop = true })
    end, { desc = "窗口操作连续模式" })

    -- Window navigation, splitting, and resizing.
    map("n", "<C-h>", "<C-w>h", { desc = "转到左侧窗口", remap = true })
    map("n", "<C-j>", "<C-w>j", { desc = "转到下方窗口", remap = true })
    map("n", "<C-k>", "<C-w>k", { desc = "转到上方窗口", remap = true })
    map("n", "<C-l>", "<C-w>l", { desc = "转到右侧窗口", remap = true })
    map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "增加窗口高度" })
    map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "减少窗口高度" })
    map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "减少窗口宽度" })
    map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "增加窗口宽度" })
    map("n", "<leader>w|", "<C-w>v", { desc = "左右分屏", remap = true })
    map("n", "<leader>w-", "<C-w>s", { desc = "上下分屏", remap = true })
    map("n", "<leader>wd", "<C-w>c", { desc = "关闭窗口", remap = true })

    -- Buffer workflow.
    map("n", "[b", "<cmd>bprevious<cr>", { desc = "上一个 Buffer" })
    map("n", "]b", "<cmd>bnext<cr>", { desc = "下一个 Buffer" })
    map("n", "<leader>bb", function()
      Snacks.picker.buffers()
    end, { desc = "浏览 Buffer" })
    map("n", "<leader>ba", function()
      Snacks.bufdelete.all()
    end, { desc = "关闭全部 Buffer" })
    map("n", "<leader>bd", function()
      Snacks.bufdelete()
    end, { desc = "关闭当前 Buffer" })
    map("n", "<leader>bo", function()
      Snacks.bufdelete.other()
    end, { desc = "关闭其他 Buffer" })

    -- File and project discovery.
    map("n", "<leader>ff", function()
      Snacks.picker.files({ cwd = LazyVim.root() })
    end, { desc = "查找项目文件" })
    map("n", "<leader>fg", function()
      Snacks.picker.grep({ cwd = LazyVim.root() })
    end, { desc = "Grep 项目文本" })
    map("n", "<leader>fe", function()
      Snacks.explorer({ cwd = vim.uv.cwd() })
    end, { desc = "打开 Explorer" })
    map("n", "<leader>fz", function()
      if vim.fn.executable("zoxide") == 0 then
        vim.notify("未找到 zoxide", vim.log.levels.ERROR)
        return
      end

      vim.system({ "zoxide", "query", "-l" }, { text = true }, function(result)
        vim.schedule(function()
          if result.code ~= 0 then
            vim.notify(vim.trim(result.stderr or "zoxide 查询失败"), vim.log.levels.ERROR)
            return
          end

          local directories = {}
          for directory in (result.stdout or ""):gmatch("[^\r\n]+") do
            directories[#directories + 1] = directory
          end
          vim.ui.select(directories, {
            prompt = "选择 Zoxide 目录",
            kind = "zoxide",
            format_item = function(directory)
              return vim.fn.fnamemodify(directory, ":~")
            end,
          }, function(directory)
            if directory then
              vim.api.nvim_set_current_dir(directory)
              vim.notify("当前目录：" .. vim.fn.fnamemodify(directory, ":~"))
            end
          end)
        end)
      end)
    end, { desc = "Zoxide 目录跳转" })

    -- Formatting and comments.
    map({ "n", "x" }, "<leader>cf", function()
      LazyVim.format({ force = true })
    end, { desc = "格式化 Code" })
    del("t", "<C-/>")
    del("t", "<C-_>")
    for _, lhs in ipairs({ "<C-/>", "<C-_>" }) do
      map("n", lhs, "gcc", { desc = "切换行注释", remap = true })
      map("x", lhs, "gc", { desc = "切换选区注释", remap = true })
      map("i", lhs, "<esc>gccgi", { desc = "切换行注释", remap = true })
    end

    -- Quickfix and diagnostic details.
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -vim.v.count1, float = true })
    end, { desc = "上一个 Diagnostic" })
    map("n", "]d", function()
      vim.diagnostic.jump({ count = vim.v.count1, float = true })
    end, { desc = "下一个 Diagnostic" })
    map("n", "[q", vim.cmd.cprev, { desc = "上一个 Quickfix 项" })
    map("n", "]q", vim.cmd.cnext, { desc = "下一个 Quickfix 项" })
    map("n", "<leader>pd", vim.diagnostic.open_float, { desc = "当前行 Problem 详情" })

    -- Git overview; hunk-local mappings are configured with gitsigns.
    map("n", "<leader>gg", function()
      Snacks.lazygit({ cwd = LazyVim.root.git() })
    end, { desc = "打开 Lazygit" })

    -- Terminal windows stay relative to the editor window so Explorer keeps its height.
    local shell = vim.fn.has("win32") == 1 and vim.fn.executable("nu.exe") == 1 and { "nu.exe" } or nil
    local function editor_window()
      local current = vim.api.nvim_get_current_win()
      if vim.bo[vim.api.nvim_win_get_buf(current)].buftype == "" then
        return current
      end
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
          return win
        end
      end
      return current
    end

    map({ "n", "t" }, "<leader>tt", function()
      Snacks.terminal.focus(shell, {
        count = 1,
        cwd = LazyVim.root(),
        win = {
          position = "bottom",
          relative = "win",
          win = editor_window(),
          height = 0.32,
        },
      })
    end, { desc = "切换底部 Terminal" })
    map({ "n", "t" }, "<leader>tf", function()
      Snacks.terminal.focus(shell, {
        count = 2,
        cwd = LazyVim.root(),
        win = {
          position = "float",
          relative = "editor",
          width = 0.85,
          height = 0.8,
          border = "rounded",
          title = " Project Terminal ",
          title_pos = "center",
        },
      })
    end, { desc = "切换悬浮 Terminal" })

    map("n", "<leader>uh", function()
      local filter = { bufnr = 0 }
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
    end, { desc = "切换 LSP 内联提示" })
end
