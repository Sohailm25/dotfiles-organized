local Client = {}
local curl = require("plenary.curl")

local GET_ISSUES_QUERY = [[
  query Issues($teamId: ID!, $projectId: ID, $after: String) {
    issues(filter: {
      team: { id: { eq: $teamId } }
      project: { id: { eq: $projectId } }
    }, first: 50, after: $after) {
      nodes {
        id
        identifier
        title
        description
        url
        priority
        priorityLabel
        state {
          id
          name
          type
        }
        assignee {
          id
          name
          email
        }
        labels {
          nodes {
            id
            name
            color
          }
        }
        createdAt
        updatedAt
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
]]

local GET_WORKFLOW_STATES_QUERY = [[
  query GetStates($teamId: String!) {
    team(id: $teamId) {
      states {
        nodes {
          id
          name
          type
          position
        }
      }
    }
  }
]]

local UPDATE_ISSUE_STATE_MUTATION = [[
  mutation UpdateIssue($id: String!, $stateId: String!) {
    issueUpdate(id: $id, input: { stateId: $stateId }) {
      success
      issue {
        id
        identifier
        state {
          id
          name
          type
        }
      }
    }
  }
]]

local CREATE_COMMENT_MUTATION = [[
  mutation CreateComment($issueId: String!, $body: String!) {
    commentCreate(input: { issueId: $issueId, body: $body }) {
      success
      comment {
        id
        body
      }
    }
  }
]]

local CREATE_ISSUE_MUTATION = [[
  mutation CreateIssue($teamId: String!, $title: String!, $projectId: String) {
    issueCreate(input: { teamId: $teamId, title: $title, projectId: $projectId }) {
      success
      issue {
        id
        identifier
        title
        url
      }
    }
  }
]]

local GET_ISSUE_COMMENTS_QUERY = [[
  query GetComments($issueId: String!) {
    issue(id: $issueId) {
      comments {
        nodes {
          id
          body
          createdAt
          user {
            name
            email
          }
        }
      }
    }
  }
]]

Client.cached_workflow_states = nil

local function get_auth_headers()
  local Config = require("linear.config.loader")
  local linear_config = Config.get_linear_config()
  return {
    ["Authorization"] = linear_config.apiToken,
    ["Content-Type"] = "application/json"
  }
end

local function map_linear_issue(raw)
  if not raw then return nil end
  
  local state = nil
  if raw.state and type(raw.state) == "table" then
    state = {
      id = raw.state.id,
      name = raw.state.name,
      type = raw.state.type,
    }
  end
  
  local assignee = nil
  if raw.assignee and type(raw.assignee) == "table" then
    assignee = {
      id = raw.assignee.id,
      name = raw.assignee.name,
      email = raw.assignee.email,
    }
  end
  
  local labels = {}
  if raw.labels and raw.labels.nodes then
    for _, label in ipairs(raw.labels.nodes) do
      table.insert(labels, {
        id = label.id,
        name = label.name,
        color = label.color,
      })
    end
  end
  
  return {
    id = raw.id,
    identifier = raw.identifier,
    title = raw.title or "Untitled",
    description = raw.description,
    url = raw.url,
    priority = raw.priority or 0,
    priorityLabel = raw.priorityLabel,
    state = state,
    assignee = assignee,
    labels = labels,
    createdAt = raw.createdAt,
    updatedAt = raw.updatedAt,
  }
end

local function make_request(query, variables)
  return curl.post("https://api.linear.app/graphql", {
    headers = get_auth_headers(),
    body = vim.json.encode({
      query = query,
      variables = variables,
    }),
    timeout = 30000,
  })
end

function Client.get_workflow_states(team_id)
  if Client.cached_workflow_states then
    return Client.cached_workflow_states
  end
  
  local response = make_request(GET_WORKFLOW_STATES_QUERY, { teamId = team_id })
  
  if not response or response.status ~= 200 then
    error("Failed to fetch workflow states")
  end
  
  local ok, data = pcall(vim.json.decode, response.body)
  if not ok or not data.data or not data.data.team or not data.data.team.states then
    error("Invalid workflow states response")
  end
  
  local states = {}
  for _, state in ipairs(data.data.team.states.nodes) do
    table.insert(states, {
      id = state.id,
      name = state.name,
      type = state.type,
      position = state.position,
    })
  end
  
  table.sort(states, function(a, b) return a.position < b.position end)
  
  Client.cached_workflow_states = states
  return states
end

function Client.update_issue_state(issue_id, state_id)
  local response = make_request(UPDATE_ISSUE_STATE_MUTATION, {
    id = issue_id,
    stateId = state_id,
  })
  
  if not response or response.status ~= 200 then
    error("Failed to update issue state")
  end
  
  local ok, data = pcall(vim.json.decode, response.body)
  if not ok then
    error("Failed to parse update response")
  end
  
  if data.errors then
    error("GraphQL error: " .. vim.inspect(data.errors))
  end
  
  if not data.data or not data.data.issueUpdate or not data.data.issueUpdate.success then
    error("Issue update failed")
  end
  
  return data.data.issueUpdate.issue
end

function Client.create_comment(issue_id, body)
  local response = make_request(CREATE_COMMENT_MUTATION, {
    issueId = issue_id,
    body = body,
  })
  
  if not response or response.status ~= 200 then
    error("Failed to create comment")
  end
  
  local ok, data = pcall(vim.json.decode, response.body)
  if not ok then
    error("Failed to parse comment response")
  end
  
  if data.errors then
    error("GraphQL error: " .. vim.inspect(data.errors))
  end
  
  if not data.data or not data.data.commentCreate or not data.data.commentCreate.success then
    error("Comment creation failed")
  end
  
  return data.data.commentCreate.comment
end

function Client.create_issue(team_id, title, project_id)
  local response = make_request(CREATE_ISSUE_MUTATION, {
    teamId = team_id,
    title = title,
    projectId = project_id,
  })
  
  if not response or response.status ~= 200 then
    error("Failed to create issue")
  end
  
  local ok, data = pcall(vim.json.decode, response.body)
  if not ok then
    error("Failed to parse issue response")
  end
  
  if data.errors then
    error("GraphQL error: " .. vim.inspect(data.errors))
  end
  
  if not data.data or not data.data.issueCreate or not data.data.issueCreate.success then
    error("Issue creation failed")
  end
  
  return data.data.issueCreate.issue
end

function Client.get_issue_comments(issue_id)
  local response = make_request(GET_ISSUE_COMMENTS_QUERY, {
    issueId = issue_id,
  })
  
  if not response or response.status ~= 200 then
    return {}
  end
  
  local ok, data = pcall(vim.json.decode, response.body)
  if not ok or not data.data or not data.data.issue or not data.data.issue.comments then
    return {}
  end
  
  local comments = {}
  for _, comment in ipairs(data.data.issue.comments.nodes) do
    if comment and type(comment) == "table" then
      table.insert(comments, {
        id = comment.id,
        body = comment.body or "",
        createdAt = comment.createdAt,
        user = comment.user and {
          name = comment.user.name or "Unknown",
          email = comment.user.email,
        } or nil,
      })
    end
  end
  
  return comments
end

function Client.get_issues_by_project(team_id, project_id)
  local all_issues = {}
  local cursor = nil
  
  repeat
    local response = make_request(GET_ISSUES_QUERY, {
      teamId = team_id,
      projectId = project_id,
      after = cursor,
    })
    
    if not response then
      error("Linear API error: No response received")
    end
    
    if response.status ~= 200 then
      error("Linear API error (HTTP " .. (response.status or "nil") .. "): " .. (response.body or "no body"))
    end
    
    local ok, data = pcall(vim.json.decode, response.body)
    if not ok then
      error("Failed to parse Linear response: " .. tostring(data))
    end
    
    if data.errors then
      error("GraphQL errors: " .. vim.inspect(data.errors))
    end
    
    if not data.data or not data.data.issues or not data.data.issues.nodes then
      error("Unexpected Linear response structure: " .. vim.inspect(data))
    end
    
    for _, raw_issue in ipairs(data.data.issues.nodes) do
      local issue = map_linear_issue(raw_issue)
      if issue then
        table.insert(all_issues, issue)
      end
    end
    
    local page_info = data.data.issues.pageInfo
    cursor = page_info and page_info.hasNextPage and page_info.endCursor
    
  until not cursor
  
  return all_issues
end

function Client.get_all_issues()
  local Config = require("linear.config.loader")
  local jobs = Config.get_all_jobs()
  local all_issues = {}
  local linear_config = Config.get_linear_config()
  
  if not linear_config.teamId then
    vim.notify("Linear: No teamId configured", vim.log.levels.ERROR)
    return all_issues
  end
  
  if not linear_config.apiToken then
    vim.notify("Linear: No apiToken configured", vim.log.levels.ERROR)
    return all_issues
  end
  
  for _, job in ipairs(jobs) do
    if job.config and job.config.linearProjectId then
      local ok, issues = pcall(Client.get_issues_by_project,
        linear_config.teamId,
        job.config.linearProjectId
      )
      
      if ok and issues then
        for _, issue in ipairs(issues) do
          issue.job_id = job.id
          issue.job_name = job.config.name
          issue.job_color = job.config.color
          issue.job_icon = job.config.icon
          table.insert(all_issues, issue)
        end
      else
        vim.notify("Linear: Failed to fetch issues for " .. job.id .. ": " .. tostring(issues), vim.log.levels.WARN)
      end
    end
  end
  
  return all_issues
end

return Client
