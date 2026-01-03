-- ABOUTME: Custom keymaps for LazyVim configuration.
-- ABOUTME: Extends default LazyVim keymaps with window navigation shortcuts.

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Cycle windows forward / backward
-- Set after VimEnter to override bufferline and other plugin mappings
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.keymap.set("n", "<Tab>", "<C-w>w", { desc = "Next window" })
    vim.keymap.set("n", "<S-Tab>", "<C-w>W", { desc = "Previous window" })
  end,
})
