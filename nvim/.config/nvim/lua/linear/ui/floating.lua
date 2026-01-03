local UI = {}
local NuiPopup = require("nui.popup")
local NuiEvent = require("nui.utils.autocmd").event

UI.state = {
  win = nil,
  buf = nil,
  issues = {},
  current_job = nil,
  selected_idx = 1,
  job_tabs = {},
  preview_win = nil,
  standup_win = nil,
  show_completed = false,
}

local function is_hidden_state(state_type)
  return state_type == "completed" or state_type == "canceled"
end

local STATE_DISPLAY_ORDER = { "started", "unstarted", "backlog", "completed", "canceled" }
local STATE_DISPLAY_NAMES = {
  started = "In Progress",
  unstarted = "To Do",
  backlog = "Backlog",
  completed = "Completed",
  canceled = "Canceled",
}

local function get_status_color(state_type)
  local colors = {
    backlog = "#8B5CF6",
    unstarted = "#6B7280", 
    started = "#F59E0B",
    completed = "#10B981",
    canceled = "#EF4444",
  }
  return colors[state_type] or "#6B7280"
end

local function get_priority_symbol(priority)
  local symbols = {
    [1] = "!",
    [2] = "⚡",
    [3] = "○",
    [4] = "◐",
    [0] = "○",
  }
  return symbols[priority] or "○"
end

local function render_status_bubble(state)
  if not state then return "○" end
  
  local symbol = state.type == "started" and "🟡" or
                state.type == "completed" and "🟢" or
                state.type == "unstarted" and "⚪" or
                state.type == "backlog" and "🔵" or "○"
  
  return symbol
end

local function render_issue(issue, idx)
  local selected = idx == UI.state.selected_idx
  local prefix = selected and "▶ " or "  "
  
  local status_bubble = render_status_bubble(issue.state)
  local priority = get_priority_symbol(issue.priority)
  local identifier = issue.identifier or "??"
  local title = issue.title or "No title"
  
  local POPUP_WIDTH = 80
  local ELLIPSIS = "..."
  local prefix_part = string.format("%s%s %s [%s] ", prefix, status_bubble, priority, identifier)
  local available_width = POPUP_WIDTH - vim.fn.strdisplaywidth(prefix_part)
  
  if vim.fn.strdisplaywidth(title) > available_width then
    local max_title_width = available_width - #ELLIPSIS
    local truncated = ""
    local width = 0
    for i = 1, #title do
      local char = title:sub(i, i)
      local char_width = vim.fn.strdisplaywidth(char)
      if width + char_width > max_title_width then
        break
      end
      truncated = truncated .. char
      width = width + char_width
    end
    title = truncated .. ELLIPSIS
  end
  
  local line = string.format(
    "%s%s %s [%s] %s",
    prefix,
    status_bubble,
    priority,
    identifier,
    title
  )
  
  return line
end

local function render_job_tab(job_id)
  local Config = require("linear.config.loader")
  local job_config = Config.get_job_config(job_id)
  if not job_config then return job_id end
  
  local icon = job_config.icon or "📋"
  local name = job_config.name or job_id
  local selected = UI.state.current_job == job_id
  
  return selected and icon .. " " .. name or " " .. name
end

local function group_issues_by_state(issues)
  local groups = {}
  for _, state_type in ipairs(STATE_DISPLAY_ORDER) do
    groups[state_type] = {}
  end
  
  for _, issue in ipairs(issues) do
    local state_type = issue.state and issue.state.type or "backlog"
    if groups[state_type] then
      table.insert(groups[state_type], issue)
    else
      table.insert(groups["backlog"], issue)
    end
  end
  
  return groups
end

local function get_filtered_issues()
  local base_issues = {}
  if UI.state.current_job then
    for _, issue in ipairs(UI.state.issues) do
      if issue.job_id == UI.state.current_job then
        if UI.state.show_completed or not is_hidden_state(issue.state and issue.state.type) then
          table.insert(base_issues, issue)
        end
      end
    end
  else
    for _, issue in ipairs(UI.state.issues) do
      if UI.state.show_completed or not is_hidden_state(issue.state and issue.state.type) then
        table.insert(base_issues, issue)
      end
    end
  end
  
  local grouped = group_issues_by_state(base_issues)
  local ordered_issues = {}
  for _, state_type in ipairs(STATE_DISPLAY_ORDER) do
    if UI.state.show_completed or not is_hidden_state(state_type) then
      for _, issue in ipairs(grouped[state_type]) do
        table.insert(ordered_issues, issue)
      end
    end
  end
  return ordered_issues
end

local function get_selected_issue()
  local filtered_issues = get_filtered_issues()
  return filtered_issues[UI.state.selected_idx]
end

local function update_buffer()
  if not UI.state.buf then return end
  
  local lines = {}
  local Config = require("linear.config.loader")
  local jobs = Config.get_all_jobs()
  table.insert(lines, "")
  
  local tab_line = "  "
  if UI.state.current_job == nil then
    tab_line = tab_line .. "📋 All  "
  else
    tab_line = tab_line .. "All  "
  end
  for _, job in ipairs(jobs) do
    tab_line = tab_line .. render_job_tab(job.id) .. "  "
  end
  table.insert(lines, tab_line)
  table.insert(lines, "")
  
  local filtered_issues = get_filtered_issues()
  
  if UI.state.current_job then
    local job_config = Config.get_job_config(UI.state.current_job)
    table.insert(lines, string.format(" %s %s (%d issues)", 
      job_config.icon or "📋",
      job_config.name or UI.state.current_job,
      #filtered_issues
    ))
  else
    table.insert(lines, string.format(" All Jobs (%d issues)", #filtered_issues))
  end
  
  table.insert(lines, string.rep("─", 60))
  
  local grouped = group_issues_by_state(filtered_issues)
  local issue_idx = 0
  
  for _, state_type in ipairs(STATE_DISPLAY_ORDER) do
    local state_issues = grouped[state_type]
    if UI.state.show_completed or not is_hidden_state(state_type) then
      local display_name = STATE_DISPLAY_NAMES[state_type] or state_type
      table.insert(lines, "")
      table.insert(lines, string.format(" ▸ %s (%d)", display_name, #state_issues))
      
      for _, issue in ipairs(state_issues) do
        issue_idx = issue_idx + 1
        table.insert(lines, render_issue(issue, issue_idx))
      end
    end
  end
  
  table.insert(lines, "")
  local completed_status = UI.state.show_completed and "✓ Shown" or "✗ Hidden"
  table.insert(lines, string.format(" Done/Canceled: %s", completed_status))
  table.insert(lines, " s: Status  c: Comment  n: New  h: Toggle Done  p: Preview  S: Standup  r: Refresh  q: Quit")
  
  vim.api.nvim_buf_set_option(UI.state.buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(UI.state.buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(UI.state.buf, "modifiable", false)
  vim.api.nvim_buf_set_option(UI.state.buf, "filetype", "linear")
end

local function toggle_preview()
  if UI.state.preview_win then
    UI.state.preview_win:unmount()
    UI.state.preview_win = nil
    return
  end
  
  local issue = get_selected_issue()
  if not issue then
    vim.notify("No issue selected", vim.log.levels.WARN)
    return
  end
  
  local function is_nil(val)
    return val == nil or val == vim.NIL or (type(val) == "string" and val == "vim.NIL")
  end
  
  local lines = {
    "",
    string.format(" %s: %s", issue.identifier, issue.title),
    " " .. string.rep("─", 68),
    string.format(" Status: %s %s", render_status_bubble(issue.state), issue.state and issue.state.name or "Unknown"),
    string.format(" Priority: %s %s", get_priority_symbol(issue.priority), issue.priorityLabel or "None"),
  }
  
  if issue.assignee and not is_nil(issue.assignee) then
    table.insert(lines, string.format(" Assignee: %s", issue.assignee.name))
  end
  
  if issue.labels and #issue.labels > 0 then
    local label_names = {}
    for _, label in ipairs(issue.labels) do
      table.insert(label_names, label.name)
    end
    table.insert(lines, string.format(" Labels: %s", table.concat(label_names, ", ")))
  end
  
  table.insert(lines, " " .. string.rep("─", 68))
  
  if not is_nil(issue.description) and issue.description ~= "" then
    table.insert(lines, "")
    local desc_str = tostring(issue.description)
    for desc_line in desc_str:gmatch("[^\r\n]+") do
      table.insert(lines, " " .. desc_line)
    end
  else
    table.insert(lines, " (No description)")
  end
  
  local Client = require("linear.client.init")
  local ok, comments = pcall(Client.get_issue_comments, issue.id)
  
  if not ok then
    table.insert(lines, "")
    table.insert(lines, " " .. string.rep("─", 68))
    table.insert(lines, string.format(" ⚠️  Error loading comments: %s", tostring(comments)))
  elseif comments and #comments > 0 then
    table.insert(lines, "")
    table.insert(lines, " " .. string.rep("─", 68))
    table.insert(lines, string.format(" 💬 Comments (%d)", #comments))
    table.insert(lines, " " .. string.rep("─", 68))
    
    for i, comment in ipairs(comments) do
      local user_name = comment.user and comment.user.name or "Unknown"
      local date = comment.createdAt and comment.createdAt:match("(%d%d%d%d%-%d%d%-%d%d)") or ""
      
      table.insert(lines, "")
      table.insert(lines, string.format(" 👤 %s (%s)", user_name, date))
      
      if comment.body and comment.body ~= "" then
        for body_line in comment.body:gmatch("[^\r\n]+") do
          table.insert(lines, "    " .. body_line)
        end
      end
      
      if i < #comments then
        table.insert(lines, "")
      end
    end
  end
  
  table.insert(lines, "")
  table.insert(lines, " [Press p or q to close]")
  
  UI.state.preview_win = NuiPopup({
    enter = true,
    focusable = true,
    zindex = 60,
    border = {
      style = "rounded",
      text = {
        top = " Preview ",
        top_align = "center",
      },
    },
    position = {
      row = "50%",
      col = "50%",
    },
    size = {
      width = 80,
      height = math.min(#lines + 2, 35),
    },
    win_options = {
      wrap = true,
    },
    buf_options = {
      modifiable = false,
      readonly = true,
    },
  })
  
  UI.state.preview_win:mount()
  vim.api.nvim_buf_set_option(UI.state.preview_win.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(UI.state.preview_win.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(UI.state.preview_win.bufnr, "modifiable", false)
  
  UI.state.preview_win:map("n", "q", function()
    toggle_preview()
  end, { noremap = true })
  
  UI.state.preview_win:map("n", "p", function()
    toggle_preview()
  end, { noremap = true })
end

local function toggle_standup()
  if UI.state.standup_win then
    UI.state.standup_win:unmount()
    UI.state.standup_win = nil
    return
  end
  
  local Config = require("linear.config.loader")
  local job_id = UI.state.current_job
  
  if not job_id then
    local jobs = Config.get_all_jobs()
    local job_names = {}
    for _, job in ipairs(jobs) do
      table.insert(job_names, job.config.name or job.id)
    end
    
    vim.ui.select(job_names, {
      prompt = "Select job for standup:",
    }, function(choice, idx)
      if choice and idx then
        job_id = jobs[idx].id
        show_standup_for_job(job_id)
      end
    end)
    return
  end
  
  show_standup_for_job(job_id)
end

function show_standup_for_job(job_id)
  local config = require("linear").config
  local standup_path = config.standups_path .. job_id .. "/standup.md"
  
  local ok, content = pcall(vim.fn.readfile, standup_path)
  if not ok or not content then
    vim.notify("Standup not found for " .. job_id, vim.log.levels.WARN)
    return
  end
  
  local lines = { "" }
  for _, line in ipairs(content) do
    table.insert(lines, " " .. line)
  end
  table.insert(lines, "")
  table.insert(lines, " [Press S or q to close]")
  
  local Config = require("linear.config.loader")
  local job_config = Config.get_job_config(job_id)
  local title = string.format(" %s Standup ", (job_config and job_config.icon or "📋") .. " " .. (job_config and job_config.name or job_id))
  
  UI.state.standup_win = NuiPopup({
    enter = true,
    focusable = true,
    zindex = 60,
    border = {
      style = "rounded",
      text = {
        top = title,
        top_align = "center",
      },
    },
    position = {
      row = "50%",
      col = "50%",
    },
    size = {
      width = 70,
      height = math.min(#lines + 2, 30),
    },
    buf_options = {
      modifiable = false,
      readonly = true,
    },
  })
  
  UI.state.standup_win:mount()
  vim.api.nvim_buf_set_option(UI.state.standup_win.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(UI.state.standup_win.bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(UI.state.standup_win.bufnr, "modifiable", false)
  
  UI.state.standup_win:map("n", "q", function()
    toggle_standup()
  end, { noremap = true })
  
  UI.state.standup_win:map("n", "S", function()
    toggle_standup()
  end, { noremap = true })
end

local function create_floating_window()
  local config = require("linear").config
  
  UI.state.win = NuiPopup({
    enter = true,
    focusable = true,
    border = {
      style = config.ui.border,
      text = {
        top = " Linear Tasks ",
        top_align = "center",
      },
    },
    position = "50%",
    size = {
      width = config.ui.width,
      height = config.ui.height,
    },
    buf_options = {
      modifiable = false,
      readonly = true,
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
      wrap = false,
    },
  })
  
  UI.state.buf = UI.state.win.bufnr
  
  UI.state.win:map("n", "j", function()
    local filtered = get_filtered_issues()
    if UI.state.selected_idx < #filtered then
      UI.state.selected_idx = UI.state.selected_idx + 1
      update_buffer()
    end
  end, { noremap = true })
  
  UI.state.win:map("n", "k", function()
    if UI.state.selected_idx > 1 then
      UI.state.selected_idx = UI.state.selected_idx - 1
      update_buffer()
    end
  end, { noremap = true })
  
  UI.state.win:map("n", "<CR>", function()
    local issue = get_selected_issue()
    if issue and issue.url then
      require("linear.utils.browser").open_url(issue.url)
    end
  end, { noremap = true })
  
  UI.state.win:map("n", "<Tab>", function()
    local Config = require("linear.config.loader")
    local jobs = Config.get_all_jobs()
    
    if UI.state.current_job == nil then
      UI.state.current_job = jobs[1] and jobs[1].id or nil
    else
      local current_idx = 0
      for idx, job in ipairs(jobs) do
        if job.id == UI.state.current_job then
          current_idx = idx
          break
        end
      end
      
      if current_idx >= #jobs then
        UI.state.current_job = nil
      else
        UI.state.current_job = jobs[current_idx + 1].id
      end
    end
    
    UI.state.selected_idx = 1
    update_buffer()
  end, { noremap = true })
  
  UI.state.win:map("n", "s", function()
    local issue = get_selected_issue()
    if not issue then
      vim.notify("No issue selected", vim.log.levels.WARN)
      return
    end
    
    local Client = require("linear.client.init")
    local Config = require("linear.config.loader")
    local linear_config = Config.get_linear_config()
    
    local ok, states = pcall(Client.get_workflow_states, linear_config.teamId)
    if not ok or not states then
      vim.notify("Failed to fetch workflow states", vim.log.levels.ERROR)
      return
    end
    
    local state_names = {}
    local current_idx = 1
    for idx, state in ipairs(states) do
      table.insert(state_names, state.name)
      if issue.state and state.id == issue.state.id then
        current_idx = idx
      end
    end
    
    vim.ui.select(state_names, {
      prompt = "Change status for " .. issue.identifier .. ":",
      format_item = function(item)
        return item
      end,
    }, function(choice, idx)
      if not choice or not idx then return end
      
      local new_state = states[idx]
      local update_ok, result = pcall(Client.update_issue_state, issue.id, new_state.id)
      
      if update_ok then
        vim.notify(string.format("Updated %s to %s", issue.identifier, new_state.name), vim.log.levels.INFO)
        require("linear.sync.poller").refresh_now()
      else
        vim.notify("Failed to update issue: " .. tostring(result), vim.log.levels.ERROR)
      end
    end)
  end, { noremap = true })
  
  UI.state.win:map("n", "c", function()
    local issue = get_selected_issue()
    if not issue then
      vim.notify("No issue selected", vim.log.levels.WARN)
      return
    end
    
    vim.ui.input({
      prompt = "Comment on " .. issue.identifier .. ": ",
    }, function(input)
      if not input or input == "" then return end
      
      local Client = require("linear.client.init")
      local ok, result = pcall(Client.create_comment, issue.id, input)
      
      if ok then
        vim.notify("Comment added to " .. issue.identifier, vim.log.levels.INFO)
      else
        vim.notify("Failed to add comment: " .. tostring(result), vim.log.levels.ERROR)
      end
    end)
  end, { noremap = true })
  
  UI.state.win:map("n", "n", function()
    local Config = require("linear.config.loader")
    local linear_config = Config.get_linear_config()
    local job_id = UI.state.current_job
    local project_id = nil
    
    if job_id then
      local job_config = Config.get_job_config(job_id)
      project_id = job_config and job_config.linearProjectId
    else
      local jobs = Config.get_all_jobs()
      local job_names = {}
      for _, job in ipairs(jobs) do
        table.insert(job_names, job.config.name or job.id)
      end
      
      vim.ui.select(job_names, {
        prompt = "Select job for new issue:",
      }, function(choice, idx)
        if not choice or not idx then return end
        job_id = jobs[idx].id
        project_id = jobs[idx].config.linearProjectId
        create_issue_with_input(linear_config.teamId, project_id, job_id)
      end)
      return
    end
    
    create_issue_with_input(linear_config.teamId, project_id, job_id)
  end, { noremap = true })
  
  UI.state.win:map("n", "h", function()
    UI.state.show_completed = not UI.state.show_completed
    UI.state.selected_idx = 1
    update_buffer()
  end, { noremap = true })
  
  UI.state.win:map("n", "p", function()
    toggle_preview()
  end, { noremap = true })
  
  UI.state.win:map("n", "S", function()
    toggle_standup()
  end, { noremap = true })
  
  UI.state.win:map("n", "q", function() UI.close() end, { noremap = true })
  UI.state.win:map("n", "<Esc>", function() UI.close() end, { noremap = true })
  
  UI.state.win:map("n", "r", function()
    require("linear.sync.poller").refresh_now()
  end, { noremap = true })
  
  UI.state.win:on(NuiEvent.BufLeave, function()
    UI.close()
  end)
  
  UI.state.win:mount()
end

function create_issue_with_input(team_id, project_id, job_id)
  vim.ui.input({
    prompt = "Issue title: ",
  }, function(input)
    if not input or input == "" then return end
    
    local Client = require("linear.client.init")
    local ok, result = pcall(Client.create_issue, team_id, input, project_id)
    
    if ok and result then
      vim.notify(string.format("Created %s: %s", result.identifier, result.title), vim.log.levels.INFO)
      require("linear.sync.poller").refresh_now()
    else
      vim.notify("Failed to create issue: " .. tostring(result), vim.log.levels.ERROR)
    end
  end)
end

function UI.toggle()
  local win_valid = false
  if UI.state.win then
    local winid = UI.state.win.winid or UI.state.win.win_id
    win_valid = winid and pcall(vim.api.nvim_win_is_valid, winid) and vim.api.nvim_win_is_valid(winid)
  end
  if win_valid then
    UI.close()
  else
    UI.show()
  end
end

function UI.show()
  local Client = require("linear.client.init")
  local Sync = require("linear.sync.poller")
  
  local cached = Sync.get_cached_issues()
  if cached and #cached > 0 then
    UI.state.issues = cached
  else
    local ok, issues = pcall(Client.get_all_issues)
    if ok and issues then
      UI.state.issues = issues
    else
      UI.state.issues = {}
      vim.notify("Linear: Failed to fetch issues: " .. tostring(issues), vim.log.levels.WARN)
    end
  end
  
  UI.state.selected_idx = 1
  
  local Config = require("linear.config.loader")
  UI.state.job_tabs = Config.get_all_jobs()
  
  create_floating_window()
  update_buffer()
end

function UI.show_job(job_id)
  local Config = require("linear.config.loader")
  local job_config = Config.get_job_config(job_id)
  
  if not job_config then
    vim.notify("Job not found: " .. job_id, vim.log.levels.ERROR)
    return
  end
  
  UI.state.current_job = job_id
  UI.show()
end

function UI.close()
  if UI.state.preview_win then
    UI.state.preview_win:unmount()
    UI.state.preview_win = nil
  end
  if UI.state.standup_win then
    UI.state.standup_win:unmount()
    UI.state.standup_win = nil
  end
  if UI.state.win then
    UI.state.win:unmount()
    UI.state.win = nil
    UI.state.buf = nil
  end
end

function UI.update_issues(issues)
  UI.state.issues = issues
  local win_valid = false
  if UI.state.win then
    local ok, valid = pcall(function()
      local winid = UI.state.win.winid or UI.state.win.win_id
      return winid and vim.api.nvim_win_is_valid(winid)
    end)
    win_valid = ok and valid
  end
  if win_valid then
    update_buffer()
  end
end

return UI
