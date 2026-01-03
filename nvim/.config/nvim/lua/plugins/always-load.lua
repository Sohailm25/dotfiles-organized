-- ~/.config/nvim/lua/plugins/always-load.lua
return {
  -- Override all the plugins shown as "Not Loaded" to load immediately
  { "catppuccin/nvim", name = "catppuccin", lazy = false },
  { "stevearc/conform.nvim", lazy = false },
  { "zbirenbaum/copilot.lua", lazy = false },
  { "lewis6991/gitsigns.nvim", lazy = false },
  { "MagicDuck/grug-far.nvim", lazy = false },
  { "folke/lazydev.nvim", lazy = false },
  { "iamcco/markdown-preview.nvim", lazy = false },
  { "nvim-mini/mini.hipatterns", lazy = false },
  { "nvim-mini/mini.icons", lazy = false },
  { "nvim-mini/mini.snippets", lazy = false },
  { "mfussenegger/nvim-lint", lazy = false },
  { "windwp/nvim-ts-autotag", lazy = false },
  { "folke/persistence.nvim", lazy = false },
  { "nvim-lua/plenary.nvim", lazy = false },
  { "MeanderingProgrammer/render-markdown.nvim", lazy = false },
  { "b0o/SchemaStore.nvim", lazy = false },
  { "folke/todo-comments.nvim", lazy = false },
  { "folke/tokyonight.nvim", lazy = false },
  { "gbprod/yanky.nvim", lazy = false },
}
