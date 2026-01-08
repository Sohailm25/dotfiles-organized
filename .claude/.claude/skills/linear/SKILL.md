---
name: linear
description: Direct Linear API access. Use ONLY when user explicitly says "Linear" (e.g., "my Linear issues", "Linear board"). For job names (Britannica, CVS, Amazon, Experian), use the jobs skill instead.
allowed-tools: Bash,Read,Glob
metadata: {"clawdis": {"primaryEnv": "LINEAR_API_KEY", "requires": {"env": ["LINEAR_API_KEY"]}}}
---

# Linear API Skill

> **Routing Note:** If the user mentions a job name (Britannica, CVS, Amazon, Experian) without explicitly saying "Linear", use the `jobs` skill instead - it handles dual-sync to both Linear and Monday.

Interact with Linear's GraphQL API to manage issues, comments, and project data.

## Global Configuration

**IMPORTANT: Before any Linear operation, read the global configuration.**

Read `~/.claude/config.json` to get:
- `linear.teamId` - Team UUID
- `linear.doneStateId` - Workflow state ID for "Done"
- `jobs.<jobId>.linearProjectId` - Project UUID for each job context

Example `~/.claude/config.json`:
```json
{
  "linear": {
    "teamId": "d5c8cdf1-1a11-4f96-ac38-0036175eafb5",
    "doneStateId": "41170148-524f-46b8-b65e-eb8e6d5bb969"
  },
  "jobs": {
    "amazon": { "name": "Amazon", "linearProjectId": "uuid-here" },
    "experian": { "name": "Experian", "linearProjectId": "uuid-here" }
  }
}
```

**Job Context Routing:**
When user mentions a job (Amazon, Experian, Britannica, CVS), use that job's `linearProjectId` for issue creation/filtering.

To read config:
```bash
cat ~/.claude/config.json | jq -r '.linear.teamId'
cat ~/.claude/config.json | jq -r '.linear.doneStateId'
cat ~/.claude/config.json | jq -r '.jobs.amazon.linearProjectId'
cat ~/.claude/config.json | jq '.jobs | keys[]'  # List all job IDs
```

## Global Prerequisites

Set these environment variables (add to `~/.zshrc`) as fallbacks:
```bash
export LINEAR_API_KEY="lin_api_..."      # Your Linear API key (required)
export LINEAR_TEAM_ID="uuid-here"         # Default team UUID (optional)
```

## API Endpoint

All requests go to: `https://api.linear.app/graphql`

## Base curl Command

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{"query": "YOUR_QUERY_HERE"}'
```

---

## Issue Operations

### Get Issue by ID or Identifier

Fetch a single issue by UUID or identifier (e.g., "ENG-123"):

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetIssue($id: String!) { issue(id: $id) { id identifier title description url priority priorityLabel state { id name type } assignee { id name email } labels { nodes { id name color } } project { id name } dueDate createdAt updatedAt } }",
    "variables": {"id": "ISSUE_ID_OR_IDENTIFIER"}
  }'
```

### List Issues with Filters

List issues with optional filtering:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query ListIssues($filter: IssueFilter, $first: Int) { issues(filter: $filter, first: $first) { nodes { id identifier title priority priorityLabel state { name type } assignee { name } project { name } dueDate } } }",
    "variables": {
      "first": 50,
      "filter": {
        "team": {"id": {"eq": "TEAM_ID"}},
        "state": {"type": {"eq": "started"}}
      }
    }
  }'
```

Filter options:
- `team.id.eq` - Filter by team UUID
- `project.id.eq` - Filter by project UUID
- `state.id.eq` - Filter by state UUID
- `state.type.eq` - Filter by state type: "backlog", "unstarted", "started", "completed", "canceled"
- `assignee.id.eq` - Filter by assignee UUID
- `priority.eq` - Filter by priority: 0 (none), 1 (urgent), 2 (high), 3 (medium), 4 (low)

### Search Issues

Full-text search across issue titles, descriptions, and comments:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query SearchIssues($query: String!, $first: Int) { searchIssues(query: $query, first: $first) { nodes { id identifier title description state { name } assignee { name } } } }",
    "variables": {"query": "search terms here", "first": 25}
  }'
```

### Create Issue

Create a new issue:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation CreateIssue($input: IssueCreateInput!) { issueCreate(input: $input) { success issue { id identifier title url } } }",
    "variables": {
      "input": {
        "teamId": "TEAM_UUID",
        "title": "Issue title",
        "description": "Issue description in markdown",
        "priority": 3,
        "projectId": "PROJECT_UUID",
        "labelIds": ["LABEL_UUID"],
        "assigneeId": "USER_UUID",
        "dueDate": "2025-01-15"
      }
    }
  }'
```

Priority values: 0 (none), 1 (urgent), 2 (high), 3 (medium), 4 (low)

### Update Issue

Update an existing issue:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation UpdateIssue($id: String!, $input: IssueUpdateInput!) { issueUpdate(id: $id, input: $input) { success issue { id identifier title state { name } } } }",
    "variables": {
      "id": "ISSUE_UUID",
      "input": {
        "title": "Updated title",
        "stateId": "STATE_UUID",
        "priority": 2,
        "assigneeId": "USER_UUID"
      }
    }
  }'
```

### Archive Issue

Archive (soft-delete) an issue:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation ArchiveIssue($id: String!) { issueArchive(id: $id) { success } }",
    "variables": {"id": "ISSUE_UUID"}
  }'
```

---

## Comment Operations

### Add Comment to Issue

Add a markdown comment to an issue:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation CreateComment($input: CommentCreateInput!) { commentCreate(input: $input) { success comment { id body createdAt } } }",
    "variables": {
      "input": {
        "issueId": "ISSUE_UUID",
        "body": "Comment text in **markdown**"
      }
    }
  }'
```

### Get Issue Comments

List all comments on an issue:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetComments($issueId: String!) { issue(id: $issueId) { comments { nodes { id body createdAt user { name } } } } }",
    "variables": {"issueId": "ISSUE_UUID"}
  }'
```

---

## Team & Project Queries

### List Teams

Get all teams in the workspace:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{"query": "query { teams { nodes { id name key } } }"}'
```

### List Projects

Get all projects for a team:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetProjects($teamId: String!) { team(id: $teamId) { projects { nodes { id name state } } } }",
    "variables": {"teamId": "TEAM_UUID"}
  }'
```

### List Labels

Get all labels for a team:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetLabels($teamId: String!) { team(id: $teamId) { labels { nodes { id name color description } } } }",
    "variables": {"teamId": "TEAM_UUID"}
  }'
```

### List Workflow States

Get all workflow states for a team:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetStates($teamId: String!) { team(id: $teamId) { states { nodes { id name type position } } } }",
    "variables": {"teamId": "TEAM_UUID"}
  }'
```

State types: "backlog", "unstarted", "started", "completed", "canceled"

### List Team Members

Get all members of a team:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetMembers($teamId: String!) { team(id: $teamId) { members { nodes { id name email displayName } } } }",
    "variables": {"teamId": "TEAM_UUID"}
  }'
```

---

## Cycle (Sprint) Operations

### List Cycles

Get all cycles for a team:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetCycles($teamId: String!) { team(id: $teamId) { cycles { nodes { id number name startsAt endsAt } } } }",
    "variables": {"teamId": "TEAM_UUID"}
  }'
```

### Get Active Cycle

To find the active cycle, query cycles and filter where `startsAt <= now <= endsAt`.

---

## Common Workflows

### Create issue and add to current sprint
1. List cycles to find active one
2. Create issue with `cycleId` set

### Move issue to Done
1. Get workflow states for the team
2. Find state with `type: "completed"`
3. Update issue with that `stateId`

### Assign issue to team member
1. List team members to get user UUID
2. Update issue with `assigneeId`
