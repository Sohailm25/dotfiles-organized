---
name: monday
description: Direct Monday.com API access. Use ONLY when user explicitly says "Monday" (e.g., "my Monday board", "Monday items"). For job names (Britannica, CVS, Amazon, Experian), use the jobs skill instead.
allowed-tools: Bash,Read,Glob
---

# Monday.com API Skill

> **Routing Note:** If the user mentions a job name (Britannica, CVS, Amazon, Experian) without explicitly saying "Monday", use the `jobs` skill instead - it handles dual-sync to both Linear and Monday.

Interact with Monday.com's GraphQL API to manage boards and items.

## Global Configuration

**IMPORTANT: Before any Monday operation, read the global configuration.**

Read `~/.claude/config.json` to get:
- `jobs.<jobId>.mondayBoardId` - Board ID for each job context

Example `~/.claude/config.json`:
```json
{
  "jobs": {
    "amazon": { "name": "Amazon", "mondayBoardId": "18393201528" },
    "experian": { "name": "Experian", "mondayBoardId": "18393201511" },
    "britannica": { "name": "Britannica", "mondayBoardId": "18393201533" },
    "cvs": { "name": "CVS", "mondayBoardId": "18393201539" }
  }
}
```

**Job Context Routing:**
When user mentions a job (Amazon, Experian, Britannica, CVS), use that job's `mondayBoardId` for item creation/queries.

To read config:
```bash
cat ~/.claude/config.json | jq -r '.jobs.amazon.mondayBoardId'
cat ~/.claude/config.json | jq '.jobs | keys[]'  # List all job IDs
cat ~/.claude/config.json | jq '.jobs | to_entries[] | "\(.key): \(.value.mondayBoardId)"'  # List all boards
```

## Global Prerequisites

Set this environment variable (add to `~/.zshrc`):
```bash
export MONDAY_API_KEY="eyJhbGciOi..."  # Your Monday.com API token
```

## API Endpoint

All requests go to: `https://api.monday.com/v2`

## Base curl Command

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{"query": "YOUR_QUERY_HERE"}'
```

---

## Board Operations

### List Boards

Get all boards in the workspace (limit 50):

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{"query": "query { boards(limit: 50) { id name state board_kind } }"}'
```

### Get Board Details

Get a specific board with its groups and columns:

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{
    "query": "query GetBoard($boardId: ID!) { boards(ids: [$boardId]) { id name groups { id title } columns { id title type } } }",
    "variables": {"boardId": "BOARD_ID"}
  }'
```

### Get Board Columns

Get column definitions for a board (useful for setting column values):

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{
    "query": "query GetBoardColumns($boardId: ID!) { boards(ids: [$boardId]) { columns { id title type settings_str } } }",
    "variables": {"boardId": "BOARD_ID"}
  }'
```

---

## Item Operations

### Create Item

Create a new item on a board:

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{
    "query": "mutation CreateItem($boardId: ID!, $itemName: String!, $groupId: String, $columnValues: JSON) { create_item(board_id: $boardId, item_name: $itemName, group_id: $groupId, column_values: $columnValues) { id name } }",
    "variables": {
      "boardId": "BOARD_ID",
      "itemName": "My new item",
      "groupId": "GROUP_ID",
      "columnValues": "{\"status\": {\"label\": \"Working on it\"}, \"date\": {\"date\": \"2025-01-15\"}}"
    }
  }'
```

Note: `columnValues` must be a JSON string (escaped). Get column IDs from `GetBoardColumns`.

### Create Item (Simple)

Create an item with just a name:

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{
    "query": "mutation { create_item(board_id: BOARD_ID, item_name: \"Item name\") { id name } }"
  }'
```

### Get Items from Board

List items from a board:

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{
    "query": "query GetItems($boardId: ID!, $limit: Int) { boards(ids: [$boardId]) { items_page(limit: $limit) { items { id name column_values { id text value } } } } }",
    "variables": {"boardId": "BOARD_ID", "limit": 50}
  }'
```

### Update Item

Update an item's column values:

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{
    "query": "mutation UpdateItem($boardId: ID!, $itemId: ID!, $columnValues: JSON!) { change_multiple_column_values(board_id: $boardId, item_id: $itemId, column_values: $columnValues) { id name } }",
    "variables": {
      "boardId": "BOARD_ID",
      "itemId": "ITEM_ID",
      "columnValues": "{\"status\": {\"label\": \"Done\"}}"
    }
  }'
```

### Archive Item

Archive (soft-delete) an item:

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{
    "query": "mutation ArchiveItem($itemId: ID!) { archive_item(item_id: $itemId) { id } }",
    "variables": {"itemId": "ITEM_ID"}
  }'
```

### Delete Item

Permanently delete an item:

```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{
    "query": "mutation DeleteItem($itemId: ID!) { delete_item(item_id: $itemId) { id } }",
    "variables": {"itemId": "ITEM_ID"}
  }'
```

---

## Column Value Formats

When setting column values, use these JSON formats:

### Status Column
```json
{"status": {"label": "Working on it"}}
```

### Date Column
```json
{"date": {"date": "2025-01-15"}}
```

### Text Column
```json
{"text_column_id": "Some text value"}
```

### People Column
```json
{"people": {"personsAndTeams": [{"id": 12345678, "kind": "person"}]}}
```

### Numbers Column
```json
{"numbers": 42}
```

### Dropdown Column
```json
{"dropdown": {"labels": ["Option 1", "Option 2"]}}
```

---

## Common Workflows

### Add task to board
1. List boards to find the target board ID
2. Get board columns to understand available fields
3. Create item with appropriate column values

### Mark item as complete
1. Get board columns to find the status column ID
2. Update item with status set to "Done" (or equivalent label)

### Move item to different group
```bash
curl -s -X POST https://api.monday.com/v2 \
  -H "Content-Type: application/json" \
  -H "Authorization: $MONDAY_API_KEY" \
  -H "API-Version: 2024-10" \
  -d '{
    "query": "mutation MoveItem($itemId: ID!, $groupId: String!) { move_item_to_group(item_id: $itemId, group_id: $groupId) { id } }",
    "variables": {"itemId": "ITEM_ID", "groupId": "TARGET_GROUP_ID"}
  }'
```
