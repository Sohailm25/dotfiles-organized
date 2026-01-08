---
name: tmux-daemon-ops
description: Generic tmux daemon management patterns. Use when user mentions "start daemon", "stop daemon", "background service", "tmux session", "daemon not running", "service management", or needs to run long-running processes in the background.
allowed-tools: Bash
---

# Tmux Daemon Operations Skill

Generic patterns for managing background daemons using tmux.

## Naming Convention

All daemon sessions use the `omo-*` prefix for easy identification:

| Daemon | Session Name |
|--------|--------------|
| Vibe-Kanban Server | `omo-vibe-kanban` |
| Linear-Vibe Sync | `omo-vibe-sync` |
| Dev Server | `omo-dev` |
| Custom | `omo-{name}` |

---

## Core Operations

### Check if Daemon Running

```bash
# Check specific daemon
tmux has-session -t omo-{name} 2>/dev/null && echo "Running" || echo "Not running"

# List all omo- daemons
tmux list-sessions 2>/dev/null | grep "^omo-" || echo "No daemons running"
```

### Start Daemon

**Basic pattern:**
```bash
tmux new-session -d -s omo-{name} -c {working_directory} "{command}"
```

**With logging:**
```bash
tmux new-session -d -s omo-{name} -c {working_directory} \
  "{command} 2>&1 | tee /tmp/{name}.log"
```

**Example - Node.js server:**
```bash
tmux new-session -d -s omo-api -c /path/to/project \
  "npm run start 2>&1 | tee /tmp/api.log"
```

**Example - Rust server with env:**
```bash
tmux new-session -d -s omo-backend -c /path/to/project \
  "PORT=3000 RUST_LOG=debug cargo run 2>&1 | tee /tmp/backend.log"
```

### Stop Daemon

```bash
tmux kill-session -t omo-{name} 2>/dev/null
```

### Restart Daemon

```bash
# Stop, wait, start
tmux kill-session -t omo-{name} 2>/dev/null
sleep 2
tmux new-session -d -s omo-{name} -c {working_directory} \
  "{command} 2>&1 | tee /tmp/{name}.log"
```

### View Daemon Output

```bash
# Attach to session (interactive)
tmux attach-session -t omo-{name}
# Detach with: Ctrl+B, then D

# View logs without attaching
tail -f /tmp/{name}.log

# View last N lines
tail -100 /tmp/{name}.log
```

---

## Advanced Patterns

### Daemon with Health Check

```bash
SESSION="omo-myservice"
LOG="/tmp/myservice.log"
HEALTH_URL="http://localhost:3000/health"

# Start daemon
tmux kill-session -t $SESSION 2>/dev/null
tmux new-session -d -s $SESSION -c /path/to/project \
  "npm start 2>&1 | tee $LOG"

# Wait for health check
for i in {1..30}; do
  if curl -s $HEALTH_URL > /dev/null 2>&1; then
    echo "Service healthy"
    break
  fi
  echo "Waiting for service... ($i/30)"
  sleep 1
done
```

### Daemon with Auto-Restart

```bash
tmux new-session -d -s omo-resilient -c /path/to/project \
  "while true; do npm start 2>&1 | tee -a /tmp/resilient.log; echo 'Crashed, restarting in 5s...'; sleep 5; done"
```

### Multiple Daemons in Sequence

```bash
# Start backend first
tmux new-session -d -s omo-backend -c /backend \
  "cargo run 2>&1 | tee /tmp/backend.log"

# Wait for backend
sleep 5

# Start frontend
tmux new-session -d -s omo-frontend -c /frontend \
  "npm run dev 2>&1 | tee /tmp/frontend.log"
```

### Daemon with Environment File

```bash
tmux new-session -d -s omo-myapp -c /path/to/project \
  "source .env && npm start 2>&1 | tee /tmp/myapp.log"
```

---

## Log Management

### Search Logs

```bash
# Search for errors
grep -i "error\|failed\|exception" /tmp/{name}.log

# Search for specific pattern
grep -i "{pattern}" /tmp/{name}.log

# Last N errors
grep -i "error" /tmp/{name}.log | tail -10
```

### Log Rotation

For long-running daemons, rotate logs:

```bash
# Rotate log before restart
mv /tmp/{name}.log /tmp/{name}.log.$(date +%Y%m%d-%H%M%S)

# Start with fresh log
tmux new-session -d -s omo-{name} -c {dir} \
  "{command} 2>&1 | tee /tmp/{name}.log"
```

### Log with Timestamps

```bash
tmux new-session -d -s omo-{name} -c {dir} \
  "{command} 2>&1 | while read line; do echo \"\$(date '+%Y-%m-%d %H:%M:%S') \$line\"; done | tee /tmp/{name}.log"
```

---

## Monitoring

### Check All Daemons

```bash
echo "=== Active Daemons ==="
tmux list-sessions 2>/dev/null | grep "^omo-" || echo "None"

echo ""
echo "=== Log Files ==="
ls -la /tmp/omo-*.log /tmp/vibe*.log 2>/dev/null || echo "No logs"
```

### Process Status

```bash
# Find daemon PID
tmux list-panes -t omo-{name} -F "#{pane_pid}"

# Check process tree
pstree -p $(tmux list-panes -t omo-{name} -F "#{pane_pid}")
```

### Resource Usage

```bash
# Get daemon PID and check resources
PID=$(tmux list-panes -t omo-{name} -F "#{pane_pid}")
ps -p $PID -o pid,ppid,%cpu,%mem,cmd
```

---

## Troubleshooting

### Daemon Won't Start

1. **Check if already running:**
   ```bash
   tmux has-session -t omo-{name} 2>/dev/null && echo "Already running"
   ```

2. **Check working directory exists:**
   ```bash
   ls -la {working_directory}
   ```

3. **Test command manually:**
   ```bash
   cd {working_directory}
   {command}
   ```

### Daemon Crashes Immediately

1. **Check log for errors:**
   ```bash
   cat /tmp/{name}.log
   ```

2. **Run interactively to debug:**
   ```bash
   tmux attach-session -t omo-{name}
   ```

### Can't Attach to Session

1. **Verify session exists:**
   ```bash
   tmux list-sessions
   ```

2. **Check tmux server:**
   ```bash
   tmux info
   ```

### Log File Empty

The daemon may have crashed before writing. Check:
```bash
# Look for recent crash logs
dmesg | tail -20

# Check system logs
log show --last 5m --predicate 'process == "{process_name}"'
```

---

## Best Practices

### DO

- Always log to a file with `| tee /tmp/{name}.log`
- Use `omo-` prefix for session names
- Kill existing session before starting new one
- Add health checks for services with HTTP endpoints
- Rotate logs for long-running daemons

### DON'T

- Don't use `&` for backgrounding (use tmux instead)
- Don't hardcode absolute paths (use variables)
- Don't ignore the working directory (`-c` flag)
- Don't skip error logging (`2>&1`)

---

## Template: New Daemon

Copy and customize this template:

```bash
#!/bin/bash
# Daemon: {name}
# Description: {what it does}

SESSION="omo-{name}"
WORKDIR="/path/to/project"
LOG="/tmp/{name}.log"
CMD="your command here"

# Stop existing
tmux kill-session -t $SESSION 2>/dev/null

# Start new
tmux new-session -d -s $SESSION -c $WORKDIR "$CMD 2>&1 | tee $LOG"

# Verify
if tmux has-session -t $SESSION 2>/dev/null; then
  echo "Started $SESSION"
  echo "Logs: $LOG"
else
  echo "Failed to start $SESSION"
  cat $LOG
  exit 1
fi
```
