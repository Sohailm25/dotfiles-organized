---
name: jobs
description: Manage tasks for job applications (Britannica, CVS, Amazon, Experian). Triggers when user mentions these company names with task intent (add, create, update, complete, list, check, delete tasks). Syncs writes to both Linear and Monday.com; reads from Linear.
allowed-tools: Bash,Read,Glob
---

# Jobs Task Management Skill

Unified task management for job applications. Syncs writes to both Linear and Monday.com, reads from Linear.

> **Dual-Sync Behavior:** All write operations (create, update, complete, delete) go to BOTH Linear and Monday.com. Read operations query Linear only (both systems should be in sync).

> **Related Skills:**
> - `standup` - View Claude-extracted accomplishments/blockers per job
> - `meetings` - Query meeting transcripts filtered by job keywords
> - `attachments` - Attach rich content (PRDs, docs) to Linear issues
> - `linear` - Direct Linear API access (use when explicitly "Linear")
> - `monday` - Direct Monday API access (use when explicitly "Monday")

---

## API Key Access

**CRITICAL:** Environment variables from `~/.zshrc` are NOT available in Claude Code's non-interactive shell. You must extract them directly:

```bash
# Extract API keys (do this FIRST, before any API calls)
LINEAR_KEY=$(grep LINEAR_API_KEY ~/.zshrc | cut -d'"' -f2)
MONDAY_KEY=$(grep MONDAY_API_KEY ~/.zshrc | cut -d'"' -f2)

# Verify they're set
echo "Linear key starts with: ${LINEAR_KEY:0:10}"
echo "Monday key starts with: ${MONDAY_KEY:0:10}"
```

The keys are defined in `~/.zshrc` as:
```bash
export LINEAR_API_KEY="lin_api_..."
export MONDAY_API_KEY="eyJhbGciOi..."
```

---

## Configuration Lookup

**CRITICAL: Always read config first to get job-specific IDs.**

```bash
# Get all job mappings
cat ~/.claude/config.json | jq '.jobs'

# Get specific job's IDs
cat ~/.claude/config.json | jq '.jobs.britannica'
# Returns: { "name": "Britannica", "mondayBoardId": "...", "linearProjectId": "..." }

# Get Linear team config
cat ~/.claude/config.json | jq '.linear'
# Returns: { "teamId": "...", "doneStateId": "..." }
```

## Job Name Normalization

Map user input to config keys:

| User says | Config key |
|-----------|------------|
| britannica, Britannica, brit, brittanica | `britannica` |
| cvs, CVS, cvs health | `cvs` |
| amazon, Amazon, amzn | `amazon` |
| experian, Experian, exp | `experian` |

Use case-insensitive matching. If ambiguous, ask for clarification.

---

## Reliable curl Patterns

Multiline curl with `-d '{...}'` causes JSON escaping issues. Use one of these patterns:

### Pattern 1: Heredoc (recommended for complex queries)
```bash
cat << 'EOF' | curl -s -X POST "https://api.linear.app/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_KEY" \
  -d @- | jq
{"query": "mutation { issueCreate(input: {teamId: \"TEAM_ID\", title: \"Task title\"}) { success issue { id identifier } } }"}
EOF
```

### Pattern 2: Single-line (for simpler queries)
```bash
curl -s -X POST "https://api.linear.app/graphql" -H "Content-Type: application/json" -H "Authorization: $LINEAR_KEY" -d '{"query": "query { issues(first: 10) { nodes { id title } } }"}' | jq
```

**Note:** Use inline mutations (values directly in query string) rather than GraphQL variables—avoids nested JSON escaping issues.

---

## Write Operations (Both Systems)

### Create Task

**Step 1: Get keys and config**
```bash
LINEAR_KEY=$(grep LINEAR_API_KEY ~/.zshrc | cut -d'"' -f2)
MONDAY_KEY=$(grep MONDAY_API_KEY ~/.zshrc | cut -d'"' -f2)

JOB_KEY="britannica"  # normalized from user input
LINEAR_PROJECT_ID=$(cat ~/.claude/config.json | jq -r ".jobs.${JOB_KEY}.linearProjectId")
MONDAY_BOARD_ID=$(cat ~/.claude/config.json | jq -r ".jobs.${JOB_KEY}.mondayBoardId")
LINEAR_TEAM_ID=$(cat ~/.claude/config.json | jq -r '.linear.teamId')
```

**Step 2: Create Linear issue**
```bash
cat << 'EOF' | curl -s -X POST "https://api.linear.app/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_KEY" \
  -d @- | jq
{"query": "mutation { issueCreate(input: {teamId: \"TEAM_ID_HERE\", projectId: \"PROJECT_ID_HERE\", title: \"TASK_TITLE\", priority: 3}) { success issue { id identifier title url } } }"}
EOF
```

**Step 3: Create Monday item**
```bash
curl -s -X POST "https://api.monday.com/v2" \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_KEY" \
  -H "API-Version: 2024-10" \
  -d '{"query": "mutation { create_item(board_id: BOARD_ID, item_name: \"TASK_TITLE\") { id name } }"}' | jq
```

**With due date (Monday):**
```bash
curl -s -X POST "https://api.monday.com/v2" \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_KEY" \
  -H "API-Version: 2024-10" \
  -d '{"query": "mutation { create_item(board_id: BOARD_ID, item_name: \"TASK_TITLE\", column_values: \"{\\\"date4\\\":\\\"2025-01-15\\\"}\") { id name } }"}' | jq
```

**Step 4: Report result**
- Show Linear issue identifier (e.g., SOH-123) and URL
- Show Monday item ID
- Confirm both created successfully

---

## Attaching Rich Content to Tasks

When adding detailed content to a task (PRDs, implementations, meeting notes, etc.),
use the **attachments skill** workflow instead of inline descriptions.

> **Reference:** See `attachments` skill for full workflow.

### When to Use Attachments vs. Description

| Scenario | Use Description | Use Attachments Skill |
|----------|----------------|----------------------|
| Short task (1-2 sentences) | Yes | No |
| PRD or design doc | No | Yes |
| Code implementation | No | Yes |
| Meeting notes | No | Yes |
| Content >50 lines | No | Yes |
| Contains code blocks | No | Yes |
| Formal document with sections | No | Yes |

---

## Read Operations (Linear Only)

### List Tasks for Job

```bash
curl -s -X POST "https://api.linear.app/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_KEY" \
  -d '{"query": "query { issues(filter: {project: {id: {eq: \"PROJECT_ID\"}}, state: {type: {nin: [\"completed\", \"canceled\"]}}}, first: 50) { nodes { id identifier title priority state { name } dueDate } } }"}' | jq
```

### Search Tasks

```bash
cat << 'EOF' | curl -s -X POST "https://api.linear.app/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_KEY" \
  -d @- | jq
{"query": "query { searchIssues(term: \"SEARCH_TERM\", filter: {project: {id: {eq: \"PROJECT_ID\"}}}, first: 10) { nodes { id identifier title state { name } } } }"}
EOF
```

**Note:** Linear uses `term` (not `query`) for searchIssues. See `sync-control` skill for troubleshooting.

---

## Update Operations

### Update Task (Fuzzy Match)

**Step 1: Search Linear for matching task** (use search above)

**Step 2: Handle matches**
- If 1 exact match: proceed
- If multiple matches: present top 3, ask user to confirm which one
- If no matches: report not found, offer to create new

**Step 3: Update Linear issue**
```bash
cat << 'EOF' | curl -s -X POST "https://api.linear.app/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_KEY" \
  -d @- | jq
{"query": "mutation { issueUpdate(id: \"ISSUE_UUID\", input: {title: \"NEW_TITLE\"}) { success issue { id identifier title } } }"}
EOF
```

**Step 4: Find and update Monday item** (search by name, then update)

---

### Complete Task

**Step 1: Search and identify task (same as Update)**

**Step 2: Get Linear done state ID from config**
```bash
DONE_STATE_ID=$(cat ~/.claude/config.json | jq -r '.linear.doneStateId')
```

**Step 3: Update Linear issue state**
```bash
cat << 'EOF' | curl -s -X POST "https://api.linear.app/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_KEY" \
  -d @- | jq
{"query": "mutation { issueUpdate(id: \"ISSUE_UUID\", input: {stateId: \"DONE_STATE_ID\"}) { success issue { id identifier title state { name } } } }"}
EOF
```

**Step 4: Update Monday item status**

`change_simple_column_value` accepts label text directly—no need to look up index:
```bash
curl -s -X POST "https://api.monday.com/v2" \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_KEY" \
  -H "API-Version: 2024-10" \
  -d '{"query": "mutation { change_simple_column_value(board_id: BOARD_ID, item_id: ITEM_ID, column_id: \"status\", value: \"Done\") { id name } }"}' | jq
```

---

### Archive/Delete Task

**Step 1: Search and identify task**

**Step 2: Archive Linear issue**
```bash
cat << 'EOF' | curl -s -X POST "https://api.linear.app/graphql" \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_KEY" \
  -d @- | jq
{"query": "mutation { issueArchive(id: \"ISSUE_UUID\") { success } }"}
EOF
```

**Step 3: Archive Monday item**
```bash
curl -s -X POST "https://api.monday.com/v2" \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_KEY" \
  -H "API-Version: 2024-10" \
  -d '{"query": "mutation { archive_item(item_id: ITEM_ID) { id } }"}' | jq
```

---

## Fuzzy Matching Strategy

When user references a task by partial name:

1. **Search Linear** using `searchIssues` with the search term, filtered by project
2. **Rank results** by title similarity to search term
3. **If single high-confidence match** (exact substring or >80% similar): proceed
4. **If multiple matches**: Present top 3 with identifiers, ask user to confirm
5. **If no matches**: Report not found, offer to create new task

---

## Error Handling

**Linear-first strategy:**
1. Execute Linear operation first
2. If Linear fails: report error, do NOT proceed to Monday
3. If Linear succeeds but Monday fails: report partial success, suggest manual Monday sync
4. If both succeed: report full success

---

## Monday Column Reference

Common column IDs (query board to confirm):
- `status` - Status column, accepts label text: "Done", "Working on it", "Stuck"
- `date4` - Date column, format: "2025-01-15"
- `person` - People column
- `name` - Item name (primary column)

To get exact column IDs for a board:
```bash
curl -s -X POST "https://api.monday.com/v2" \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_KEY" \
  -H "API-Version: 2024-10" \
  -d '{"query": "query { boards(ids: [BOARD_ID]) { columns { id title type } } }"}' | jq
```

---

## Common Workflows

### "Add 'prepare for phone screen' to Britannica"
1. Extract API keys from ~/.zshrc
2. Normalize "Britannica" → `britannica`
3. Read config for IDs
4. Create Linear issue with title "prepare for phone screen"
5. Create Monday item with same title
6. Report both IDs

### "What tasks do I have for Amazon?"
1. Extract LINEAR_KEY
2. Normalize "Amazon" → `amazon`
3. Read config for `linearProjectId`
4. Query Linear for non-completed issues in that project
5. Format and display list

### "What did I accomplish at Amazon this week?"
Use the `standup` skill - it shows Claude-extracted accomplishments from meeting transcripts:
```bash
head -80 ~/Repos/experiments/assistant/standups/amazon/standup.md
```

### "What meetings did I have for Amazon?"
Use the `meetings` skill - query synced meeting transcripts filtered by job keywords:
```bash
grep -rl -E "(amazon|aws)" ~/Repos/experiments/assistant/meetings/ --include="*.md"
```

### "Complete the 'submit application' task for CVS"
1. Extract API keys
2. Normalize "CVS" → `cvs`
3. Search Linear for "submit application" in CVS project
4. If found, update Linear state to Done
5. Find matching Monday item, update status to "Done"
6. Report completion

### "Attach PRD to Amazon task SOH-15"
1. Normalize "Amazon" → `amazon`
2. Verify SOH-15 exists in Amazon project (Linear search)
3. Use `attachments` skill workflow
4. Report success with both issue URL and gist URL
