---
name: linear-vibe-sync
description: Manage the Linear-Vibe bidirectional sync daemon. Use when user mentions "sync daemon", "linear sync", "vibe sync", "task not syncing", "SSE events", "sync issues", or debugging synchronization between Linear and vibe-kanban.
allowed-tools: Bash,Read,Glob,Edit
---

# Linear-Vibe Sync Daemon Skill

Manage the bidirectional sync daemon between Linear issues and vibe-kanban tasks.

## Quick Reference

| Item | Value |
|------|-------|
| Tmux Session | `omo-vibe-sync` |
| Log File | `/tmp/vibe-sync.log` |
| State File | `~/Repos/experiments/assistant/data/vibe-sync-state.json` |
| Source Code | `~/Repos/experiments/assistant/src/sync/` |
| Vibe-kanban API | `http://localhost:65371` |

---

## Daemon Management

### Check Status

```bash
# Check if daemon is running
tmux has-session -t omo-vibe-sync 2>/dev/null && echo "Running" || echo "Not running"

# View recent logs
tail -20 /tmp/vibe-sync.log
```

### Start Daemon

```bash
# Kill existing if any
tmux kill-session -t omo-vibe-sync 2>/dev/null

# Start sync daemon
tmux new-session -d -s omo-vibe-sync -c /Users/sohailmo/Repos/experiments/assistant \
  "bun run src/sync/linear-vibe-daemon.ts 2>&1 | tee /tmp/vibe-sync.log"

echo "Started sync daemon. Logs: /tmp/vibe-sync.log"
```

### Stop Daemon

```bash
tmux kill-session -t omo-vibe-sync 2>/dev/null
echo "Stopped sync daemon"
```

### Restart Daemon

```bash
tmux kill-session -t omo-vibe-sync 2>/dev/null
sleep 1
tmux new-session -d -s omo-vibe-sync -c /Users/sohailmo/Repos/experiments/assistant \
  "bun run src/sync/linear-vibe-daemon.ts 2>&1 | tee /tmp/vibe-sync.log"
echo "Restarted sync daemon"
```

### View Logs

```bash
# Tail logs
tail -f /tmp/vibe-sync.log

# Search for sync events
grep -i "sync\|linear\|vibe" /tmp/vibe-sync.log | tail -30

# Search for errors
grep -i "error\|failed" /tmp/vibe-sync.log | tail -20

# Search for SSE events
grep -i "sse\|event\|patch" /tmp/vibe-sync.log | tail -20
```

---

## Architecture

### Sync Flow

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Linear    │◀───────▶│  Sync Daemon │◀───────▶│ Vibe-Kanban │
│   (Issues)  │         │   (TypeScript)│         │   (Tasks)   │
└─────────────┘         └──────────────┘         └─────────────┘
       │                       │                        │
       │    Webhook/Poll       │      SSE Events       │
       │◀──────────────────────│───────────────────────▶│
```

### Direction

| Source | Target | Trigger |
|--------|--------|---------|
| Linear → Vibe | Task update | Issue state change, new issue |
| Vibe → Linear | Issue update | Task marked "Done" via SSE |

---

## SSE Event Detection

The daemon connects to vibe-kanban's SSE endpoint to detect task completions.

### Event Types

| Event | Description |
|-------|-------------|
| `patch` | Task field update (including status) |
| `insert` | New task created |
| `delete` | Task deleted |

### Done Detection Logic

Located in `src/sync/linear-vibe-daemon.ts`:

```typescript
function extractTaskIdFromDonePatch(data: any): string | null {
  // Handles full task replacement patches where status is "Done"
  // Returns task_id if status changed to Done, null otherwise
}
```

The daemon:
1. Connects to `http://localhost:65371/api/sse`
2. Listens for `patch` events
3. Checks if `data.status === "Done"`
4. Extracts `task_id` from the patch
5. Updates corresponding Linear issue to Done state

### Deduplication

The daemon maintains a `processedDoneEvents` Set to avoid processing the same completion twice:
- Events are deduplicated by `task_id`
- Set is cleared periodically to prevent memory growth

---

## State Management

### State File Location

```bash
cat ~/Repos/experiments/assistant/data/vibe-sync-state.json
```

### State Structure

```json
{
  "lastSyncTime": "2025-12-29T15:00:00.000Z",
  "taskMappings": {
    "vibe-task-id": "LINEAR-123",
    ...
  }
}
```

### Reset State

```bash
# Backup and reset
cp ~/Repos/experiments/assistant/data/vibe-sync-state.json \
   ~/Repos/experiments/assistant/data/vibe-sync-state.json.bak
echo '{"lastSyncTime": null, "taskMappings": {}}' > \
   ~/Repos/experiments/assistant/data/vibe-sync-state.json
```

---

## Debugging Sync Issues

### Task Not Syncing to Linear

1. **Check daemon is running**
   ```bash
   tmux has-session -t omo-vibe-sync 2>/dev/null && echo "Running" || echo "Not running"
   ```

2. **Check SSE connection**
   ```bash
   grep -i "sse\|connected" /tmp/vibe-sync.log | tail -10
   ```

3. **Check for errors**
   ```bash
   grep -i "error\|failed\|404" /tmp/vibe-sync.log | tail -20
   ```

4. **Verify task mapping exists**
   ```bash
   cat ~/Repos/experiments/assistant/data/vibe-sync-state.json | jq '.taskMappings'
   ```

### SSE Not Detecting Events

1. **Verify vibe-kanban is running**
   ```bash
   curl -s http://localhost:65371/health
   ```

2. **Test SSE endpoint directly**
   ```bash
   curl -N http://localhost:65371/api/sse 2>&1 | head -20
   ```

3. **Check event format in logs**
   ```bash
   grep "patch\|event" /tmp/vibe-sync.log | tail -10
   ```

### Linear Update Failing

1. **Check Linear API key**
   ```bash
   echo $LINEAR_API_KEY | head -c 20
   ```

2. **Test Linear API**
   ```bash
   curl -s -X POST https://api.linear.app/graphql \
     -H "Content-Type: application/json" \
     -H "Authorization: $LINEAR_API_KEY" \
     -d '{"query": "{ viewer { id name } }"}' | jq
   ```

3. **Check for 404 errors (deleted issues)**
   ```bash
   grep "404" /tmp/vibe-sync.log
   ```

---

## Source Files

| File | Purpose |
|------|---------|
| `src/sync/linear-vibe-daemon.ts` | Main daemon entry point |
| `src/sync/merge-handler.ts` | Handles sync operations |
| `src/sync/sse-client.ts` | SSE connection management |
| `data/vibe-sync-state.json` | Persistent state |

---

## Error Handling

### 404 Errors (Deleted Issues)

When a Linear issue is deleted but vibe-kanban still references it:
- Daemon logs warning but continues
- Task mapping is cleaned up
- No crash or retry loop

### SSE Disconnection

When SSE connection drops:
- Daemon attempts reconnection with exponential backoff
- Logs reconnection attempts
- Resumes event processing on reconnect

### Duplicate Events

The daemon deduplicates events using:
1. `processedDoneEvents` Set for completion events
2. Event timestamps to skip stale events

---

## Configuration

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `LINEAR_API_KEY` | Yes | Linear API token |
| `VIBE_KANBAN_URL` | No | Override vibe-kanban URL (default: localhost:65371) |

### Linear Config

Read from `~/.claude/config.json`:

```json
{
  "linear": {
    "teamId": "uuid",
    "doneStateId": "uuid"
  }
}
```

---

## Manual Sync Operations

### Force Sync Single Task

```bash
# Get task from vibe-kanban
TASK=$(curl -s http://localhost:65371/api/tasks/{task_id})
echo $TASK | jq

# Update Linear issue manually
LINEAR_ISSUE_ID="SOH-123"
DONE_STATE_ID=$(cat ~/.claude/config.json | jq -r '.linear.doneStateId')

curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation { issueUpdate(id: \"'$LINEAR_ISSUE_ID'\", input: { stateId: \"'$DONE_STATE_ID'\" }) { success } }"
  }' | jq
```

### Trigger Full Resync

```bash
# Reset state and restart daemon
echo '{"lastSyncTime": null, "taskMappings": {}}' > \
   ~/Repos/experiments/assistant/data/vibe-sync-state.json

tmux kill-session -t omo-vibe-sync 2>/dev/null
tmux new-session -d -s omo-vibe-sync -c /Users/sohailmo/Repos/experiments/assistant \
  "bun run src/sync/linear-vibe-daemon.ts 2>&1 | tee /tmp/vibe-sync.log"
```
