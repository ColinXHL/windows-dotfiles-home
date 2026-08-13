local function disable(keys)
  return vim.tbl_map(function(key)
    if type(key) == "table" then
      return { key[1], false, mode = key.mode }
    end
    return { key, false }
  end, keys)
end

return {
  {
    "folke/flash.nvim",
    enabled = true,
    opts = {
      modes = {
        char = { enabled = false },
      },
    },
    keys = {
      { "s", false, mode = { "n", "x", "o" } },
      { "S", false, mode = { "n", "x", "o" } },
      { "r", false, mode = "o" },
      { "R", false, mode = { "o", "x" } },
      { "<C-s>", false, mode = "c" },
      { "<C-Space>", false, mode = { "n", "x", "o" } },
      {
        "<leader>jj",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x", "o" },
        desc = "Flash 快速跳转",
      },
      {
        "<leader>jl",
        function()
          require("flash").jump({
            search = { mode = "search", max_length = 0 },
            label = { after = { 0, 0 } },
            pattern = "^",
          })
        end,
        mode = { "n", "x", "o" },
        desc = "Flash 跳转到行",
      },
      {
        "<leader>jt",
        function()
          require("flash").treesitter()
        end,
        mode = { "n", "x", "o" },
        desc = "Flash Treesitter 选择",
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          keys = {
            normal_ctrl_q = {
              "<C-q>",
              function()
                vim.cmd.stopinsert()
              end,
              desc = "进入 Terminal 普通模式",
              mode = "t",
            },
          },
        },
      },
    },
    keys = vim.list_extend(
      disable({
        "<leader>.",
        "<leader>:",
        "<leader>E",
        "<leader>S",
        "<leader>dps",
        "<leader>fB",
        "<leader>fb",
        "<leader>fc",
        "<leader>fe",
        "<leader>fE",
        "<leader>ff",
        "<leader>fF",
        "<leader>fg",
        "<leader>fp",
        "<leader>fr",
        "<leader>fR",
        "<leader>gD",
        "<leader>gd",
        "<leader>gi",
        "<leader>gI",
        "<leader>gp",
        "<leader>gP",
        "<leader>gs",
        "<leader>gS",
        "<leader>n",
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
        "<leader>sR",
        "<leader>su",
        { "<leader>sw", mode = { "n", "x" } },
        { "<leader>sW", mode = { "n", "x" } },
        "<leader>uC",
        "<leader>un",
      }),
      {
        {
          "<leader>e",
          function()
            Snacks.explorer({ cwd = LazyVim.root() })
          end,
          desc = "Explorer (Root Dir)",
        },
      }
    ),
  },
  {
    "mikavilpas/yazi.nvim",
    version = "*",
    lazy = false,
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "<leader>fy",
        "<cmd>Yazi cwd<cr>",
        desc = "打开 Yazi 文件管理器",
      },
    },
    opts = {
      open_for_directories = true,
      change_neovim_cwd_on_close = true,
      floating_window_scaling_factor = 0.95,
      yazi_floating_window_border = "rounded",
      yazi_floating_window_winblend = 0,
      keymaps = {
        show_help = "<f1>",
        copy_relative_path_to_selected_files = false,
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      if not vim.g.neovide then
        return
      end

      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        mode = "buffers",
        indicator = { icon = "▎", style = "icon" },
        separator_style = { "", "" },
        max_name_length = 28,
        get_element_icon = function(element)
          local category = element.directory and "directory" or "file"
          local name = vim.fn.fnamemodify(element.path, ":t")
          local icon = require("mini.icons").get(category, name)
          return icon
        end,
        show_buffer_close_icons = false,
        show_close_icon = false,
        always_show_bufferline = true,
      })

      local mocha = {
        crust = "#11111b",
        mantle = "#181825",
        text = "#cdd6f4",
        overlay0 = "#6c7086",
        mauve = "#cba6f7",
        yellow = "#f9e2af",
      }
      local original_highlights = opts.highlights
      opts.highlights = function(defaults)
        local highlights = type(original_highlights) == "function" and original_highlights(defaults)
          or original_highlights
          or {}
        local merged = vim.tbl_deep_extend("force", highlights, {
          fill = { bg = mocha.crust },
          background = { fg = mocha.text, bg = mocha.mantle },
          buffer_visible = { fg = mocha.text, bg = mocha.mantle },
          buffer_selected = { fg = mocha.crust, bg = mocha.mauve, bold = true, italic = false },
          modified = { fg = mocha.yellow, bg = mocha.mantle },
          modified_visible = { fg = mocha.yellow, bg = mocha.mantle },
          modified_selected = { fg = mocha.crust, bg = mocha.mauve },
          duplicate = { fg = mocha.overlay0, bg = mocha.mantle, italic = true },
          duplicate_visible = { fg = mocha.overlay0, bg = mocha.mantle, italic = true },
          duplicate_selected = { fg = mocha.crust, bg = mocha.mauve, italic = false },
          separator = { fg = mocha.crust, bg = mocha.mantle },
          separator_visible = { fg = mocha.crust, bg = mocha.mantle },
          separator_selected = { fg = mocha.crust, bg = mocha.mauve },
          indicator_selected = { fg = mocha.crust, bg = mocha.mauve },
        })

        for _, group in ipairs({
          "buffer_selected",
          "numbers_selected",
          "diagnostic_selected",
          "hint_selected",
          "hint_diagnostic_selected",
          "info_selected",
          "info_diagnostic_selected",
          "warning_selected",
          "warning_diagnostic_selected",
          "error_selected",
          "error_diagnostic_selected",
          "modified_selected",
          "duplicate_selected",
          "separator_selected",
          "indicator_selected",
          "pick_selected",
        }) do
          merged[group] = vim.tbl_deep_extend("force", merged[group] or {}, {
            bg = mocha.mauve,
            fg = mocha.crust,
          })
        end

        return merged
      end
    end,
    keys = disable({
      "<S-h>",
      "<S-l>",
      "[B",
      "]B",
      "<leader>bj",
      "<leader>bl",
      "<leader>bp",
      "<leader>bP",
      "<leader>br",
    }),
  },
  {
    "folke/noice.nvim",
    keys = disable({
      "<leader>sn",
      "<leader>sna",
      "<leader>snd",
      "<leader>snh",
      "<leader>snl",
      "<leader>snt",
    }),
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "super-tab",
        ["<CR>"] = { "fallback" },
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    lazy = false,
    cmd = {
      "OverseerClose",
      "OverseerOpen",
      "OverseerRun",
      "OverseerShell",
      "OverseerTaskAction",
      "OverseerToggle",
    },
    opts = {
      dap = false,
      task_list = {
        direction = "bottom",
        max_height = { 24, 0.3 },
        min_height = 8,
      },
      form = {
        border = "rounded",
        win_opts = { winblend = 0 },
      },
      task_win = {
        border = "rounded",
        win_opts = { winblend = 0 },
      },
    },
    keys = {
      {
        "<leader>rr",
        function()
          local overseer = require("overseer")
          overseer.run_task({}, function(task)
            if task then
              overseer.run_action(task, "open float")
            end
          end)
        end,
        desc = "选择并运行 Task",
      },
      {
        "<leader>rb",
        function()
          local overseer = require("overseer")
          overseer.run_task({ tags = { overseer.TAG.BUILD } }, function(task)
            if task then
              overseer.run_action(task, "open float")
            end
          end)
        end,
        desc = "选择并运行 Build Task",
      },
      {
        "<leader>rt",
        function()
          local overseer = require("overseer")
          overseer.run_task({ tags = { overseer.TAG.TEST } }, function(task)
            if task then
              overseer.run_action(task, "open float")
            end
          end)
        end,
        desc = "选择并运行 Test Task",
      },
      { "<leader>rs", "<cmd>OverseerShell<cr>", desc = "运行临时 Shell Task" },
      { "<leader>rl", "<cmd>OverseerToggle bottom<cr>", desc = "切换 Task 列表" },
      { "<leader>ra", "<cmd>OverseerTaskAction<cr>", desc = "操作当前 Task" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      preset = "classic",
      show_help = false,
      win = {
        border = "none",
        col = 0,
        row = math.huge,
        width = math.huge,
        padding = { 1, 2 },
        no_overlap = false,
      },
      layout = {
        width = { min = 22 },
        spacing = 3,
      },
      icons = {
        rules = {
          { pattern = "buffer", icon = "󰓩 ", color = "cyan" },
          { pattern = "文件", icon = "󰈔 ", color = "cyan" },
          { pattern = "查找", icon = " ", color = "green" },
          { pattern = "搜索", icon = " ", color = "green" },
          { pattern = "grep", icon = " ", color = "green" },
          { pattern = "explorer", icon = "󰙅 ", color = "cyan" },
          { pattern = "yazi", icon = "󰇥 ", color = "cyan" },
          { pattern = "zoxide", icon = "󰉋 ", color = "blue" },
          { pattern = "窗口", icon = " ", color = "blue" },
          { pattern = "分屏", icon = "󰖲 ", color = "blue" },
          { pattern = "terminal", icon = " ", color = "red" },
          { pattern = "task", icon = "󰑮 ", color = "orange" },
          { pattern = "运行", icon = "󰑮 ", color = "orange" },
          { pattern = "code", icon = " ", color = "orange" },
          { pattern = "lsp", icon = " ", color = "orange" },
          { pattern = "symbol", icon = " ", color = "orange" },
          { pattern = "函数", icon = "󰊕 ", color = "orange" },
          { pattern = "calls", icon = "󰑐 ", color = "orange" },
          { pattern = "source/header", icon = "󰈙 ", color = "orange" },
          { pattern = "problem", icon = "󱖫 ", color = "red" },
          { pattern = "diagnostic", icon = "󱖫 ", color = "red" },
          { pattern = "quickfix", icon = "󰁨 ", color = "yellow" },
          { pattern = "todo", icon = "󰄬 ", color = "yellow" },
          { pattern = "git", icon = "󰊢 ", color = "orange" },
          { pattern = "跳转", icon = "󰉁 ", color = "purple" },
          { pattern = "flash", icon = "󰉁 ", color = "purple" },
          { pattern = "markdown", icon = " ", color = "blue" },
          { pattern = "折叠", icon = " ", color = "yellow" },
          { pattern = "mason", icon = "󰔷 ", color = "blue" },
          { pattern = "session", icon = " ", color = "azure" },
          { pattern = "保存", icon = " ", color = "azure" },
          { pattern = "退出", icon = "󰈆 ", color = "red" },
          { pattern = "注释", icon = "󰅺 ", color = "grey" },
          { pattern = "格式化", icon = " ", color = "cyan" },
        },
      },
      spec = {
        { "<leader>b", group = "Buffer", icon = { icon = "󰓩 ", color = "cyan" } },
        { "<leader>c", group = "Code/LSP", icon = { icon = " ", color = "orange" } },
        { "<leader>f", group = "文件/查找", icon = { icon = " ", color = "green" } },
        { "<leader>g", group = "Git", icon = { icon = "󰊢 ", color = "orange" } },
        { "<leader>gh", group = "Git hunk", icon = { icon = "󰊢 ", color = "orange" } },
        { "<leader>j", group = "跳转", icon = { icon = "󰉁 ", color = "purple" } },
        { "<leader>p", group = "Problems", icon = { icon = "󱖫 ", color = "red" } },
        { "<leader>q", group = "Session/退出", icon = { icon = "󰆴 ", color = "azure" } },
        { "<leader>r", group = "运行/Task", icon = { icon = "󰑮 ", color = "orange" } },
        { "<leader>t", group = "Terminal", icon = { icon = " ", color = "red" } },
        { "<leader>u", group = "UI", icon = { icon = "󰙵 ", color = "cyan" } },
        { "<leader>w", group = "窗口", icon = { icon = "󰖲 ", color = "blue" } },
        { "<leader>l", icon = { icon = "󰒲 ", color = "blue" } },
        { "<leader>?", icon = { icon = "󰋖 ", color = "cyan" } },
        { "<leader>w|", icon = { icon = " ", color = "blue" } },
        { "<leader>w-", icon = { icon = " ", color = "blue" } },
        { "<leader>wd", icon = { icon = "󰅖 ", color = "red" } },
        { "[", group = "上一个", icon = { icon = " ", color = "blue" } },
        { "]", group = "下一个", icon = { icon = " ", color = "blue" } },
        { "g", group = "跳转到", icon = { icon = "󰉁 ", color = "purple" } },
        { "z", group = "折叠", icon = { icon = " ", color = "yellow" } },
        { "za", desc = "切换当前折叠" },
        { "zo", desc = "打开当前折叠" },
        { "zc", desc = "关闭当前折叠" },
        { "zR", desc = "打开全部折叠" },
        { "zM", desc = "关闭全部折叠" },
        { "<C-w>=", desc = "均分所有窗口" },
      },
    },
  },
  {
    "folke/persistence.nvim",
    keys = disable({ "<leader>qd", "<leader>ql", "<leader>qS" }),
  },
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      { "<leader>sr", false, mode = { "n", "x" } },
      {
        "<leader>fr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "x" },
        desc = "项目搜索与替换",
      },
    },
  },
  {
    "stevearc/conform.nvim",
    keys = disable({ { "<leader>cF", mode = { "n", "x" } } }),
    opts = function(_, opts)
      opts.formatters_by_ft.markdown = nil
      opts.formatters_by_ft["markdown.mdx"] = nil
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "markdownlint-cli2" and tool ~= "markdown-toc"
      end, opts.ensure_installed or {})
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft["markdown.mdx"] = {}
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "切换 Markdown 浏览器预览",
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    config = function(_, opts)
      local render_markdown = require("render-markdown")
      render_markdown.setup(opts)
      Snacks.toggle({
        name = "Markdown 终端渲染",
        get = render_markdown.get,
        set = render_markdown.set,
        wk_desc = { enabled = "关闭 ", disabled = "开启 " },
      }):map("<leader>um", { desc = "切换 Markdown 终端渲染" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.marksman = { enabled = false }
      opts.servers["*"].keys = {
        { "gd", vim.lsp.buf.definition, desc = "跳转到定义", has = "definition" },
        { "gD", vim.lsp.buf.declaration, desc = "跳转到声明", has = "declaration" },
        { "gy", vim.lsp.buf.type_definition, desc = "跳转到类型定义", has = "typeDefinition" },
        { "gI", vim.lsp.buf.implementation, desc = "跳转到实现", has = "implementation" },
        { "gr", vim.lsp.buf.references, desc = "查找引用", nowait = true },
        { "K", vim.lsp.buf.hover, desc = "查看 LSP 文档" },
        { "gK", vim.lsp.buf.signature_help, desc = "查看函数签名", has = "signatureHelp" },
        {
          "<leader>fs",
          function()
            Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter })
          end,
          desc = "查找当前文件 Symbol",
          has = "documentSymbol",
        },
        {
          "<leader>fS",
          function()
            Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter })
          end,
          desc = "查找项目 Symbol",
          has = "workspace/symbols",
        },
        {
          "<leader>ci",
          function()
            Snacks.picker.lsp_incoming_calls()
          end,
          desc = "查看 Incoming Calls",
          has = "callHierarchy/incomingCalls",
        },
        {
          "<leader>co",
          function()
            Snacks.picker.lsp_outgoing_calls()
          end,
          desc = "查看 Outgoing Calls",
          has = "callHierarchy/outgoingCalls",
        },
        {
          "<leader>ca",
          vim.lsp.buf.code_action,
          desc = "执行 Code Action",
          mode = { "n", "x" },
          has = "codeAction",
        },
        { "<leader>cr", vim.lsp.buf.rename, desc = "重命名 Symbol", has = "rename" },
      }

      opts.servers.clangd = opts.servers.clangd or {}
      opts.servers.clangd.keys = vim.list_extend(opts.servers.clangd.keys or {}, {
        { "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "切换 Source/Header" },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts.on_attach = function(buffer)
        local gs = require("gitsigns")
        local function map(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = buffer, desc = desc, silent = true })
        end

        map("]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "下一个 Git hunk")
        map("[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "上一个 Git hunk")
        map("<leader>ghp", gs.preview_hunk_inline, "预览当前 Git hunk")
      end
    end,
  },
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>xx", false },
      { "<leader>xX", false },
      { "<leader>cs", false },
      { "<leader>cS", false },
      { "<leader>xL", false },
      { "<leader>xQ", false },
      { "<leader>pp", "<cmd>Trouble diagnostics toggle<cr>", desc = "项目 Problems 面板" },
      {
        "<leader>pb",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "当前 Buffer Problems 面板",
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "下一个 TODO/FIXME",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "上一个 TODO/FIXME",
      },
      { "<leader>xt", false },
      { "<leader>xT", false },
      { "<leader>st", false },
      { "<leader>sT", false },
    },
  },
}
