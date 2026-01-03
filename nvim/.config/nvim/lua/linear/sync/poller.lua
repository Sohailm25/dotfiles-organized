local Sync = {}
local loop = vim.loop

Sync.state = {
  timer = nil,
  cached_issues = nil,
  last_update = 0,
}

local function debounce(func, delay)
  local timer_id = nil
  return function(...)
    local args = {...}
    if timer_id then
      loop.timer_stop(timer_id)
    end
    timer_id = loop.new_timer()
    loop.timer_start(timer_id, delay, 0, function()
      func(unpack(args))
      timer_id = nil
    end)
  end
end

local function fetch_issues()
  vim.schedule(function()
    local Client = require("linear.client.init")
    local UI = require("linear.ui.floating")
    
    local success, issues = pcall(Client.get_all_issues)
    if not success then
      vim.notify("Linear sync error: " .. tostring(issues), vim.log.levels.ERROR)
      return
    end
    
    Sync.state.cached_issues = issues
    Sync.state.last_update = os.time()
    
    UI.update_issues(issues)
  end)
end

local debounced_fetch = debounce(fetch_issues, 5000)

function Sync.start_polling()
  local config = require("linear").config
  
  if Sync.state.timer then
    loop.timer_stop(Sync.state.timer)
  end
  
  Sync.state.timer = loop.new_timer()
  
  function tick()
    debounced_fetch()
  end
  
  loop.timer_start(Sync.state.timer, config.refresh_interval, 0, tick)
end

function Sync.stop_polling()
  if Sync.state.timer then
    loop.timer_stop(Sync.state.timer)
    Sync.state.timer = nil
  end
end

function Sync.refresh_now()
  fetch_issues()
end

function Sync.get_cached_issues()
  return Sync.state.cached_issues
end

function Sync.is_cache_fresh()
  local max_age = require("linear").config.refresh_interval
  local now = os.time()
  return (now - Sync.state.last_update) < max_age
end

function Sync.cleanup()
  Sync.stop_polling()
  Sync.state.cached_issues = nil
  Sync.state.last_update = 0
end

return Sync