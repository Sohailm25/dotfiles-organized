return {
  "sohail/linear.nvim",
  dir = vim.fn.stdpath("config") .. "/lua/linear",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim"
  },
  config = function()
    require("linear").setup({
      config_path = "/Users/sohailmo/Repos/experiments/assistant/data/config.json",
      jobs_path = "/Users/sohailmo/Repos/experiments/assistant/data/jobs/",
      standups_path = "/Users/sohailmo/Repos/experiments/assistant/standups/",
      refresh_interval = 60000,
      ui = {
        width = 80,
        height = 20,
        border = "rounded"
      }
    })
  end,
}
