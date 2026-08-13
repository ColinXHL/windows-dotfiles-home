return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      -- Neovide needs a Normal background color for normal_opacity to blend.
      transparent_background = not vim.g.neovide,
      float = {
        transparent = false,
        solid = true,
      },
      lsp_styles = {
        inlay_hints = {
          background = false,
        },
      },
      integrations = {
        overseer = true,
      },
      styles = {
        comments = {},
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
