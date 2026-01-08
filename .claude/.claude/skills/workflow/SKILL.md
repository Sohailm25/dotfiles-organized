---
name: workflow
description: Manage GitHub Actions workflows for the assistant pipeline. Use when user mentions "workflow", "sync workflow", "did my sync run", "trigger sync", "workflow status", "github action", "daily-sync", or asks about automation schedule.
allowed-tools: Bash,Read
---

# GitHub Actions Workflow Skill

Manage the `daily-sync.yml` workflow that runs the Limitless → Linear automation.

## Quick Reference

| Item | Value |
|------|-------|
| Workflow File | `.github/workflows/daily-sync.yml` |
| Repository | `Sohailm25/assistant` |
| Schedule | 8x daily (CST): 6AM, 8AM, 10AM, 12PM, 2PM, 4PM, 6PM, 10PM |
| Pipeline | `python -m src.main process` |

## Schedule (CST → UTC)

| CST | UTC | Cron |
|-----|-----|------|
| 6 AM | 12:00 | `0 12 * * *` |
| 8 AM | 14:00 | `0 14 * * *` |
| 10 AM | 16:00 | `0 16 * * *` |
| 12 PM | 18:00 | `0 18 * * *` |
| 2 PM | 20:00 | `0 20 * * *` |
| 4 PM | 22:00 | `0 22 * * *` |
| 6 PM | 00:00 | `0 0 * * *` |
| 10 PM | 04:00 | `0 4 * * *` |

---

## Trigger Workflow Manually

```bash
# Trigger for today
gh workflow run daily-sync.yml -R Sohailm25/assistant

# Trigger for specific date
gh workflow run daily-sync.yml -R Sohailm25/assistant -f target_date=2025-12-28
```

---

## Check Workflow Status

### Latest Run

```bash
gh run list --workflow=daily-sync.yml -R Sohailm25/assistant --limit=1
```

### Recent Runs (Last 5)

```bash
gh run list --workflow=daily-sync.yml -R Sohailm25/assistant --limit=5
```

### Detailed Run Info

```bash
# Get run ID from list command, then:
gh run view <RUN_ID> -R Sohailm25/assistant
```

---

## View Workflow Logs

### Full Logs

```bash
gh run view <RUN_ID> -R Sohailm25/assistant --log
```

### Filtered Logs (Common Patterns)

```bash
# Check for Linear sync
gh run view <RUN_ID> -R Sohailm25/assistant --log 2>/dev/null | grep -iE "(linear|issue|created|synced)"

# Check for errors
gh run view <RUN_ID> -R Sohailm25/assistant --log 2>/dev/null | grep -iE "(error|failed|exception)"

# Check action items extracted
gh run view <RUN_ID> -R Sohailm25/assistant --log 2>/dev/null | grep -i "action items"

# Check HTTP responses
gh run view <RUN_ID> -R Sohailm25/assistant --log 2>/dev/null | grep "HTTP"
```

---

## Wait for Running Workflow

```bash
# List in-progress runs
gh run list --workflow=daily-sync.yml -R Sohailm25/assistant --status=in_progress

# Watch a specific run until completion
gh run watch <RUN_ID> -R Sohailm25/assistant
```

---

## Re-run Failed Workflow

```bash
# Re-run failed jobs only
gh run rerun <RUN_ID> -R Sohailm25/assistant --failed

# Re-run entire workflow
gh run rerun <RUN_ID> -R Sohailm25/assistant
```

---

## Common Workflows

### "Did my 6PM sync run?"

```bash
# Check recent runs, look for one around 6PM CST (00:00 UTC)
gh run list --workflow=daily-sync.yml -R Sohailm25/assistant --limit=3
```

### "Why didn't issues get created?"

1. Check the run completed successfully:
   ```bash
   gh run list --workflow=daily-sync.yml -R Sohailm25/assistant --limit=1
   ```

2. Check logs for action item extraction:
   ```bash
   gh run view <RUN_ID> -R Sohailm25/assistant --log 2>/dev/null | grep -i "action items"
   ```

3. Check if lifelogs were already processed (see `sync-control` skill)

### "Trigger sync for yesterday's meetings"

```bash
gh workflow run daily-sync.yml -R Sohailm25/assistant -f target_date=$(date -v-1d +%Y-%m-%d)
```

---

## Troubleshooting

### Workflow Not Triggering on Schedule

- Cron uses UTC, not CST
- GitHub may delay cron jobs by up to 15 minutes during high load
- Manual trigger always works: `gh workflow run daily-sync.yml -R Sohailm25/assistant`

### Workflow Fails Immediately

Check for:
- Missing secrets (`LIMITLESS_API_KEY`, `ANTHROPIC_API_KEY`, `LINEAR_API_KEY`)
- Python dependency issues

```bash
gh run view <RUN_ID> -R Sohailm25/assistant --log 2>/dev/null | head -100
```

### Workflow Succeeds But No Output

- Lifelogs may already be processed (check `sync-control` skill)
- No meetings recorded for that date
- Check sync state: `cat ~/Repos/experiments/assistant/data/sync-state.json`
