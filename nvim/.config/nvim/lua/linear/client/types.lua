local Types = {}

Types.LinearIssue = {
  id = "",
  identifier = "",
  title = "",
  description = "",
  url = "",
  priority = 0,
  priorityLabel = "",
  state = {},
  assignee = {},
  labels = {},
  job_id = "",
  job_name = "",
  job_color = "",
  job_icon = "",
  createdAt = "",
  updatedAt = "",
}

Types.LinearLabel = {
  id = "",
  name = "",
  color = "",
  description = "",
}

Types.LinearState = {
  id = "",
  name = "",
  type = "",
}

Types.LinearAssignee = {
  id = "",
  name = "",
  email = "",
}

return Types