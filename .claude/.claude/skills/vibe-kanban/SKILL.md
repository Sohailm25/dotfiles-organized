---
name: vibe-kanban
description: Manage vibe-kanban agent orchestration server. Use when user mentions "vibe-kanban", "vibe kanban", "agent stuck", "task stuck in running", "restart vibe", "vibe server", "kanban board", debugging agent execution issues, or checking task/agent status.
allowed-tools: Bash,Read,Glob,Edit
---

# Vibe-Kanban Agent Orchestration Skill

Manage the vibe-kanban server that orchestrates AI coding agents (Claude Code, opencode, Codex, etc.).

## Quick Reference

| Item | Value |
|------|-------|
| Backend Port | `65371` (configurable via `PORT` env) |
| Frontend Port | `3000` (dev mode) |
| Tmux Session | `omo-vibe-kanban` |
| Log File | `/tmp/vibe-kanban.log` |
| Codebase | `/Users/sohailmo/Repos/experiments/assistant/vibe-kanban` |
| Database | SQLite (local), Postgres (remote) |

---

## Server Management

### Check Server Status

```bash
# Check if server is running
tmux has-session -t omo-vibe-kanban 2>/dev/null && echo "Running" || echo "Not running"

# Check port is listening
lsof -i :65371 | grep LISTEN

# Health check
curl -s http://localhost:65371/health 2>/dev/null || echo "Server not responding"
```

### Start Server

```bash
# Kill existing session if any
tmux kill-session -t omo-vibe-kanban 2>/dev/null

# Start with debug logging
tmux new-session -d -s omo-vibe-kanban -c /Users/sohailmo/Repos/experiments/assistant/vibe-kanban \
  "PORT=65371 DISABLE_WORKTREE_ORPHAN_CLEANUP=1 RUST_LOG=debug cargo run --bin server 2>&1 | tee /tmp/vibe-kanban.log"

echo "Started vibe-kanban server. Logs: /tmp/vibe-kanban.log"
```

### Stop Server

```bash
tmux kill-session -t omo-vibe-kanban 2>/dev/null
echo "Stopped vibe-kanban server"
```

### Restart Server

```bash
tmux kill-session -t omo-vibe-kanban 2>/dev/null
sleep 2
tmux new-session -d -s omo-vibe-kanban -c /Users/sohailmo/Repos/experiments/assistant/vibe-kanban \
  "PORT=65371 DISABLE_WORKTREE_ORPHAN_CLEANUP=1 RUST_LOG=debug cargo run --bin server 2>&1 | tee /tmp/vibe-kanban.log"
echo "Restarted vibe-kanban server"
```

### View Logs

```bash
# Tail logs
tail -f /tmp/vibe-kanban.log

# Search for errors
grep -i "error\|failed\|panic" /tmp/vibe-kanban.log | tail -20

# Search for orphan cleanup
grep -i "orphan" /tmp/vibe-kanban.log
```

---

## Debugging Stuck Agents

### Symptoms
- Task shows "Running" in UI but no agent process exists
- "Stop" button doesn't work
- Agent crashed without callback (OOM, SIGKILL, etc.)

### Root Cause
Vibe-kanban uses fire-and-forget for agent execution. If an agent dies without calling back, the task state remains "running" forever.

### Detection

```bash
# Check for orphaned executions in logs
grep "orphan" /tmp/vibe-kanban.log

# On server restart, orphans are detected:
# "Found orphaned execution process {id} for session {session_id}"
```

### Recovery Options

**Option 1: Restart Server (triggers orphan cleanup)**
```bash
tmux kill-session -t omo-vibe-kanban 2>/dev/null
sleep 2
tmux new-session -d -s omo-vibe-kanban -c /Users/sohailmo/Repos/experiments/assistant/vibe-kanban \
  "PORT=65371 RUST_LOG=debug cargo run --bin server 2>&1 | tee /tmp/vibe-kanban.log"
```

**Option 2: Wait for Periodic Cleanup**
The server runs orphan cleanup every 5 minutes automatically. Check logs:
```bash
grep "periodic orphan" /tmp/vibe-kanban.log
```

### Orphan Cleanup Mechanism

Located in `crates/services/src/services/container.rs` (lines 214-299):
1. Queries `ExecutionProcess::find_running()` for all "running" processes
2. Marks each as "Failed" with no exit code
3. Updates task status to "InReview"
4. Logs detection for debugging

Runs:
- At server startup (once)
- Every 5 minutes (periodic, added in `crates/server/src/main.rs`)

---

## API Reference

Base URL: `http://localhost:65371`

### Tasks

```bash
# List all tasks
curl -s http://localhost:65371/api/tasks | jq

# Get specific task
curl -s http://localhost:65371/api/tasks/{task_id} | jq

# Create task
curl -s -X POST http://localhost:65371/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Task title", "description": "Description"}' | jq
```

### Executions

```bash
# List executions for a task
curl -s http://localhost:65371/api/tasks/{task_id}/executions | jq

# Get execution status
curl -s http://localhost:65371/api/executions/{execution_id} | jq
```

### Projects

```bash
# List projects
curl -s http://localhost:65371/api/projects | jq
```

---

## Codebase Structure

```
vibe-kanban/
├── crates/
│   ├── server/src/main.rs      # Server entry point, startup tasks
│   ├── services/               # Business logic
│   │   └── container.rs        # cleanup_orphan_executions()
│   ├── db/                     # SQLx models and migrations
│   ├── executors/              # Agent execution (Claude, Codex, etc.)
│   ├── deployment/             # Deployment trait and config
│   ├── local-deployment/       # Local SQLite deployment
│   └── utils/                  # Shared utilities
├── frontend/                   # React + TypeScript UI
└── shared/                     # Generated TS types from Rust
```

### Key Files

| File | Purpose |
|------|---------|
| `crates/server/src/main.rs` | Server startup, background tasks |
| `crates/services/src/services/container.rs` | Core service container, orphan cleanup |
| `crates/db/src/models/execution_process.rs` | Execution process model |
| `crates/executors/src/` | Agent executor implementations |

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` or `BACKEND_PORT` | `0` (auto) | Server port |
| `HOST` | `127.0.0.1` | Server host |
| `RUST_LOG` | `info` | Log level (debug, info, warn, error) |
| `DISABLE_WORKTREE_ORPHAN_CLEANUP` | unset | Disable git worktree cleanup |

---

## Common Issues

### Server Won't Start

1. **Port in use**
   ```bash
   lsof -i :65371 | grep LISTEN
   kill -9 <PID>
   ```

2. **Database locked**
   ```bash
   # Check for stale lock
   ls -la ~/.vibe-kanban/*.db*
   ```

3. **Compilation error**
   ```bash
   cd /Users/sohailmo/Repos/experiments/assistant/vibe-kanban
   cargo check 2>&1 | head -50
   ```

### Task Stuck in "Running"

See "Debugging Stuck Agents" section above.

### Frontend Not Loading

1. Check backend is running: `curl http://localhost:65371/health`
2. Check frontend dev server: `cd frontend && pnpm dev`
3. Check CORS/port mismatch in browser console

---

## Development Commands

```bash
# Full dev environment (frontend + backend)
cd /Users/sohailmo/Repos/experiments/assistant/vibe-kanban
pnpm run dev

# Backend only with watch
pnpm run backend:dev:watch

# Frontend only
cd frontend && pnpm dev

# Type check
cargo check --workspace
pnpm run check

# Run tests
cargo test --workspace

# Generate TS types from Rust
pnpm run generate-types
```

---

## Integration with Linear

Vibe-kanban tasks can sync with Linear issues via the linear-vibe-sync daemon.
See the `linear-vibe-sync` skill for daemon management.

When a task is marked "Done" in vibe-kanban:
1. SSE event is emitted
2. Sync daemon detects via `extractTaskIdFromDonePatch()`
3. Corresponding Linear issue is updated to "Done" state
