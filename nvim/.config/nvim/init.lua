-- Fix nvim-treesitter vim query incompatibility with Neovim 0.11+
-- Must run BEFORE lazy.nvim loads plugins to prevent noice.nvim errors
-- nvim-treesitter's vim/highlights.scm contains "tab" which is invalid for the bundled parser
do
  local bundled_query = vim.fn.expand("$VIMRUNTIME/queries/vim/highlights.scm")
  if vim.fn.filereadable(bundled_query) == 1 then
    local content = table.concat(vim.fn.readfile(bundled_query), "\n")
    vim.treesitter.query.set("vim", "highlights", content)
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.keymap.set("n", "<leader>z", ":ZenMode<CR>", { silent = true })
vim.keymap.set("n", "<leader>m", ":Markview<CR>", { silent = true })
vim.keymap.set("n", "<leader>ms", ":Markview splitToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>p", ":TypstPreview<CR>", {
  desc = "Preview Typst document",
  silent = true,
})

-- TYPST AND TINYMIST CONFIG
local lspconfig = require("lspconfig")

-- Set up tinymist for Typst files
lspconfig.tinymist.setup({
  -- Optional settings
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onType", -- Export PDF on typing
    outputPath = "$root/target/$dir/$name", -- Where PDFs are saved
  },
})

-- Ensure .typ files are recognized as Typst
vim.filetype.add({
  extension = {
    typ = "typst",
  },
})
