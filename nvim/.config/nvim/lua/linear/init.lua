local Linear = {}

Linear.config = {
  config_path = "/Users/sohailmo/Repos/experiments/assistant/data/config.json",
  jobs_path = "/Users/sohailmo/Repos/experiments/assistant/data/jobs/",
  standups_path = "/Users/sohailmo/Repos/experiments/assistant/standups/",
  refresh_interval = 60000,
  ui = {
    width = 80,
    height = 20,
    border = "rounded",
  },
}
local Client = require("linear.client.init")
local UI = require("linear.ui.floating")
local Sync = require("linear.sync.poller")
local Config = require("linear.config.loader")

function Linear.setup(opts)
  Linear.config = vim.tbl_deep_extend("force", Linear.config, opts or {})
  Config.load(Linear.config)
  Linear.setup_keymaps()
  Linear.setup_commands()
  Sync.start_polling()
end

function Linear.setup_keymaps()
  vim.keymap.set("n", "<leader>1", UI.toggle, { desc = "Linear Tasks" })
  vim.keymap.set("n", "<leader>1a", function() UI.show_job("amazon") end, { desc = "Linear: Amazon" })
  vim.keymap.set("n", "<leader>1c", function() UI.show_job("cvs") end, { desc = "Linear: CVS" })
  vim.keymap.set("n", "<leader>1b", function() UI.show_job("britannica") end, { desc = "Linear: Britannica" })
  vim.keymap.set("n", "<leader>1e", function() UI.show_job("experian") end, { desc = "Linear: Experian" })
end

function Linear.setup_commands()
  vim.api.nvim_create_user_command("Linear", function()
    vim.schedule(function()
      UI.toggle()
    end)
  end, { desc = "Toggle Linear tasks popup" })
  
  vim.api.nvim_create_user_command("LinearAmazon", function()
    vim.schedule(function()
      UI.show_job("amazon")
    end)
  end, { desc = "Show Linear tasks for Amazon" })
  
  vim.api.nvim_create_user_command("LinearCVS", function()
    vim.schedule(function()
      UI.show_job("cvs")
    end)
  end, { desc = "Show Linear tasks for CVS" })
  
  vim.api.nvim_create_user_command("LinearBritannica", function()
    vim.schedule(function()
      UI.show_job("britannica")
    end)
  end, { desc = "Show Linear tasks for Britannica" })
  
  vim.api.nvim_create_user_command("LinearExperian", function()
    vim.schedule(function()
      UI.show_job("experian")
    end)
  end, { desc = "Show Linear tasks for Experian" })
end

function Linear.health()
  vim.health.start("Linear.nvim")
  
  local has_plenary = pcall(require, "plenary")
  local has_nui = pcall(require, "nui")
  
  if has_plenary then
    vim.health.ok("plenary.nvim installed")
  else
    vim.health.error("plenary.nvim not found")
  end
  
  if has_nui then
    vim.health.ok("nui.nvim installed")
  else
    vim.health.error("nui.nvim not found")
  end
  
  local config_path = Linear.config.config_path
  local jobs_path = Linear.config.jobs_path
  local standups_path = Linear.config.standups_path
  
  if vim.fn.filereadable(config_path) == 1 then
    vim.health.ok("Config file found: " .. config_path)
  else
    vim.health.error("Config file not found: " .. config_path)
  end
  
  if vim.fn.isdirectory(jobs_path) == 1 then
    vim.health.ok("Jobs directory found: " .. jobs_path)
  else
    vim.health.error("Jobs directory not found: " .. jobs_path)
  end
  
  if vim.fn.isdirectory(standups_path) == 1 then
    vim.health.ok("Standups directory found: " .. standups_path)
  else
    vim.health.warn("Standups directory not found: " .. standups_path)
  end
end

return Linear
