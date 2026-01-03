local Config = {}

local default_config = {}

function Config.load(plugin_config)
  local config_path = plugin_config.config_path
  local jobs_path = plugin_config.jobs_path
  
  if vim.fn.filereadable(config_path) == 1 then
    local content = vim.fn.readfile(config_path)
    local ok, data = pcall(vim.json.decode, table.concat(content, "\n"))
    if ok then
      default_config = data
    else
      vim.notify("Failed to parse Linear config: " .. data, vim.log.levels.ERROR)
    end
  end
  
  Config.jobs = {}
  local job_files = vim.fn.glob(jobs_path .. "*.json", false, true)
  
  for _, file in ipairs(job_files) do
    local job_id = vim.fn.fnamemodify(file, ":t:r")
    local content = vim.fn.readfile(file)
    local ok, job_data = pcall(vim.json.decode, table.concat(content, "\n"))
    
    if ok then
      Config.jobs[job_id] = job_data
    else
      vim.notify("Failed to parse job config: " .. job_id, vim.log.levels.ERROR)
    end
  end
end

function Config.get_linear_config()
  return default_config.linear or {}
end

function Config.get_job_config(job_id)
  return Config.jobs[job_id]
end

function Config.get_all_jobs()
  local job_list = {}
  for job_id, config in pairs(Config.jobs) do
    if config.linearProjectId then
      table.insert(job_list, { id = job_id, config = config })
    end
  end
  -- Sort alphabetically by job name for consistent ordering
  table.sort(job_list, function(a, b)
    return (a.config.name or a.id) < (b.config.name or b.id)
  end)
  return job_list
end

return Config