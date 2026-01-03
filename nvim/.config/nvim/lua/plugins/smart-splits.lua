-- ABOUTME: smart-splits.nvim for seamless navigation between Neovim and tmux panes
-- ABOUTME: Uses Ctrl+Arrow keys to navigate, works with tmux via @pane-is-vim variable

return {
  "mrjones2014/smart-splits.nvim",
  lazy = false, -- Load immediately to set @pane-is-vim for tmux
  config = function()
    require("smart-splits").setup({
      -- Ignored buffer types (won't navigate away from these)
      ignored_buftypes = { "nofile", "quickfix", "prompt" },
      -- Ignored filetypes
      ignored_filetypes = { "NvimTree", "neo-tree" },
      -- Default resize amount
      default_amount = 3,
      -- At edge behavior: 'wrap', 'split', 'stop', or function
      at_edge = "stop",
      -- Move cursor to same row in destination
      move_cursor_same_row = false,
      -- Whether to resize buffers as cursor moves
      cursor_follows_swapped_bufs = false,
      -- Multiplexer integration (auto-detected)
      multiplexer_integration = nil,
      -- Disable nav when tmux pane is zoomed
      disable_multiplexer_nav_when_zoomed = true,
      -- Log level
      log_level = "info",
    })

    -- Navigation keymaps: Ctrl+Arrow
    vim.keymap.set("n", "<C-Left>", require("smart-splits").move_cursor_left, { desc = "Move to left pane" })
    vim.keymap.set("n", "<C-Down>", require("smart-splits").move_cursor_down, { desc = "Move to pane below" })
    vim.keymap.set("n", "<C-Up>", require("smart-splits").move_cursor_up, { desc = "Move to pane above" })
    vim.keymap.set("n", "<C-Right>", require("smart-splits").move_cursor_right, { desc = "Move to right pane" })

    -- Resize keymaps: Alt+Arrow (optional, for resizing splits)
    vim.keymap.set("n", "<A-Left>", require("smart-splits").resize_left, { desc = "Resize left" })
    vim.keymap.set("n", "<A-Down>", require("smart-splits").resize_down, { desc = "Resize down" })
    vim.keymap.set("n", "<A-Up>", require("smart-splits").resize_up, { desc = "Resize up" })
    vim.keymap.set("n", "<A-Right>", require("smart-splits").resize_right, { desc = "Resize right" })

    -- Swap buffer keymaps (optional): Leader+Leader+Arrow
    vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left, { desc = "Swap buffer left" })
    vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down, { desc = "Swap buffer down" })
    vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up, { desc = "Swap buffer up" })
    vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right, { desc = "Swap buffer right" })
  end,
}
