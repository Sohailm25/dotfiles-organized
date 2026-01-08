---
name: beads-ecosystem
description: Issue tracking, task management, and multi-agent coordination. Use for managing tasks, tracking dependencies, planning work, coordinating between agents, or file reservations. Covers bd (beads CLI), bv (graph-aware triage), and mcp-agent-mail (agent coordination).
allowed-tools: Bash,Read,Glob
---

# Beads Ecosystem

Unified issue tracking and multi-agent coordination system combining three tools:
- **bd (beads)**: Dependency-aware issue database and CLI
- **bv (beads-viewer)**: Graph-aware triage engine with metrics
- **mcp-agent-mail**: Agent coordination layer with file reservations

---

## bd (Beads CLI)

Lightweight, dependency-aware issue tracking. Use for ALL task management.

### Quick Reference

```bash
# Check ready work (unblocked issues)
bd ready --json

# Create issue
bd create "Issue title" -t bug|feature|task -p 0-4 --json
bd create "Found bug" -p 1 --deps discovered-from:bd-123 --json

# Update issue
bd update bd-42 --status in_progress --json
bd update bd-42 --priority 1 --json

# Complete work
bd close bd-42 --reason "Completed" --json
```

### Issue Types
| Type | Use For |
|------|---------|
| bug | Something broken |
| feature | New functionality |
| task | Work items (tests, docs, refactoring) |
| epic | Large feature with subtasks |
| chore | Maintenance (dependencies, tooling) |

### Priorities
| Level | Meaning |
|-------|---------|
| 0 | Critical (security, data loss, broken builds) |
| 1 | High (major features, important bugs) |
| 2 | Medium (default) |
| 3 | Low (polish, optimization) |
| 4 | Backlog (future ideas) |

### Workflow
1. `bd ready` → shows unblocked issues
2. `bd update id --status in_progress` → claim task
3. Work on it
4. Discover new work? `bd create "Found X" --deps discovered-from:parent-id`
5. `bd close id --reason "Done"` → complete
6. Commit `.beads/issues.jsonl` with code changes

---

## bv (Beads Viewer)

Graph-aware triage engine. Use instead of parsing beads.jsonl—computes PageRank, critical paths, cycles, parallel tracks.

**CRITICAL**: Use ONLY `--robot-*` flags. Bare `bv` launches interactive TUI that blocks session.

### Primary Commands

```bash
# THE MEGA-COMMAND: Start here for triage
bv --robot-triage
# Returns: quick_ref, recommendations, quick_wins, blockers_to_clear, project_health, commands

# Just the single top pick
bv --robot-next

# Parallel execution tracks
bv --robot-plan

# Full graph metrics (PageRank, betweenness, HITS, cycles, etc.)
bv --robot-insights

# Priority misalignment detection
bv --robot-priority
```

### Filtering & Scoping

```bash
bv --robot-plan --label backend           # Scope to label
bv --robot-insights --as-of HEAD~30       # Historical point-in-time
bv --recipe actionable --robot-plan       # Ready to work (no blockers)
bv --recipe high-impact --robot-triage    # Top PageRank scores
bv --robot-triage --robot-triage-by-track # Group by work streams
bv --robot-triage --robot-triage-by-label # Group by domain
```

### jq Examples

```bash
bv --robot-triage | jq '.quick_ref'                    # At-a-glance summary
bv --robot-triage | jq '.recommendations[0]'          # Top recommendation
bv --robot-plan | jq '.plan.summary.highest_impact'   # Best unblock target
bv --robot-insights | jq '.Cycles'                    # Circular deps (must fix!)
```

### Output Format
- `data_hash`: Fingerprint of source (verify consistency)
- `status`: Per-metric state (`computed|approx|timeout|skipped`)
- Phase 1 (instant): degree, topo sort, density
- Phase 2 (async, 500ms): PageRank, betweenness, HITS, cycles

---

## mcp-agent-mail

Coordination layer for multi-agent workflows. Provides identities, inbox/outbox, file reservations.

### Benefits
- Prevents agents stepping on each other (file reservations)
- Keeps communication out of token budget
- Human-auditable artifacts in Git

### Quick Start (Same Repository)

```bash
# 1. Register agent
ensure_project, then register_agent using repo's absolute path as project_key

# 2. Reserve files before editing
file_reservation_paths(project_key, agent_name, ["src/**"], ttl_seconds=3600, exclusive=true)

# 3. Communicate
send_message(..., thread_id="FEAT-123")
fetch_inbox
acknowledge_message

# 4. Read fast
resource://inbox/{Agent}?project=<abs-path>&limit=20
resource://thread/{id}?project=<abs-path>&include_bodies=true
```

### Tool Categories

**Macros** (speed/smaller models):
- `macro_start_session`
- `macro_prepare_thread`
- `macro_file_reservation_cycle`
- `macro_contact_handshake`

**Granular** (fine control):
- `register_agent`
- `file_reservation_paths`
- `send_message`
- `fetch_inbox`
- `acknowledge_message`

### Common Pitfalls
| Error | Fix |
|-------|-----|
| `from_agent not registered` | `register_agent` in correct `project_key` first |
| `FILE_RESERVATION_CONFLICT` | Adjust patterns, wait for expiry, or use non-exclusive |

---

## Integrated Workflow: bd + bv + agent-mail

When coordinating multi-agent work with issue tracking:

### Conventions
- Use Beads for task status/priority/dependencies
- Use Agent Mail for conversation, decisions, attachments
- Use Beads issue id (e.g., `bd-123`) as Mail `thread_id`
- Prefix message subjects with `[bd-123]`

### Typical Flow

```bash
# 1. Pick ready work
bd ready --json
# Choose highest priority, no blockers

# 2. Reserve edit surface
file_reservation_paths(project_key, agent_name, ["src/**"], ttl_seconds=3600, exclusive=true, reason="bd-123")

# 3. Announce start
send_message(..., thread_id="bd-123", subject="[bd-123] Start: <title>", ack_required=true)

# 4. Work and update
# Reply in-thread with progress, attach artifacts

# 5. Complete and release
bd close bd-123 --reason "Completed"
release_file_reservations(project_key, agent_name, paths=["src/**"])
# Final Mail reply: "[bd-123] Completed" with summary
```

### Mapping Cheatsheet
| Mail Field | Beads Field |
|------------|-------------|
| `thread_id` | `bd-###` |
| `subject` | `[bd-###] ...` |
| `file_reservation.reason` | `bd-###` |
| `commit_message` (optional) | Include `bd-###` |

---

## Rules

**ALLOWED:**
- Use bd for ALL task tracking
- Always use --json flag for programmatic use
- Link discovered work with discovered-from dependencies
- Check `bd ready` before asking "what should I work on?"

**FORBIDDEN:**
- Do NOT create markdown TODO lists
- Do NOT use external issue trackers
- Do NOT duplicate tracking systems
- Do NOT parse beads.jsonl directly—use bv
