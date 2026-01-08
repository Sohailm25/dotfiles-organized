---
name: sync-control
description: Manage assistant pipeline sync state and troubleshooting. Use when user mentions "sync state", "reset sync", "force reprocess", "why didn't it sync", "processed lifelogs", "Linear not working", "pipeline issue", or debugging sync problems.
allowed-tools: Bash,Read,Write,Glob
---

# Sync Control Skill

Manage the assistant pipeline's sync state and troubleshoot common issues.

## Quick Reference

| Item | Value |
|------|-------|
| Sync State | `~/Repos/experiments/assistant/data/sync-state.json` |
| Config | `~/Repos/experiments/assistant/data/config.json` |
| Pipeline | `src/processing/pipeline.py` |
| Linear Client | `src/linear/client.py` |

---

## Check Sync State

### View Current State

```bash
cat ~/Repos/experiments/assistant/data/sync-state.json | jq
```

### Check What's Been Processed

```bash
cat ~/Repos/experiments/assistant/data/sync-state.json | jq '.processedLifelogIds'
```

### Check Last Sync Time

```bash
cat ~/Repos/experiments/assistant/data/sync-state.json | jq '{lastPollTimestamp, lastSyncDate}'
```

---

## Reset Sync State

### Full Reset (Force Reprocess Everything)

```bash
cd ~/Repos/experiments/assistant

cat > data/sync-state.json << 'EOF'
{
  "version": 2,
  "lastPollTimestamp": null,
  "lastSyncDate": null,
  "processedLifelogIds": [],
  "pollerEnabled": false,
  "pollerIntervalMs": 300000
}
EOF

git add data/sync-state.json
git commit -m "reset: clear sync state to force reprocessing"
git push
```

### Partial Reset (Remove Specific Lifelog IDs)

```bash
cd ~/Repos/experiments/assistant

# View current IDs
cat data/sync-state.json | jq '.processedLifelogIds'

# Edit to remove specific IDs, then commit
git add data/sync-state.json
git commit -m "reset: remove specific lifelog IDs from processed list"
git push
```

---

## Sync State Format

```json
{
  "version": 2,
  "lastPollTimestamp": "2025-12-29T16:53:12.571332",
  "lastSyncDate": "2025-12-29",
  "processedLifelogIds": [
    "Kci2DGhhvqpnTrSW85Bn",
    "NyStMqcCpnBcBixWFa84"
  ],
  "pollerEnabled": false,
  "pollerIntervalMs": 300000
}
```

| Field | Purpose |
|-------|---------|
| `version` | State format version (always 2) |
| `lastPollTimestamp` | ISO timestamp of last processing |
| `lastSyncDate` | Date string of last sync |
| `processedLifelogIds` | Array of lifelog UUIDs already processed |
| `pollerEnabled` | Whether background poller is enabled |
| `pollerIntervalMs` | Polling interval (not used by GitHub Actions) |

---

## Troubleshooting Guide

### Issue: Linear API Returns 400/401

**Symptom:** HTTP 400 Bad Request or 401 Unauthorized from Linear

**Root Cause:** Linear API keys should NOT have "Bearer" prefix.

**Fix Location:** `src/linear/client.py`

```python
# WRONG
"Authorization": f"Bearer {self.api_key}"

# CORRECT  
"Authorization": self.api_key
```

**Verification:**
```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{"query": "{ viewer { id name } }"}' | jq
```

---

### Issue: Linear searchIssues Returns Schema Error

**Symptom:** `Unknown argument "query" on field "Query.searchIssues"`

**Root Cause:** Linear renamed the argument from `query` to `term`.

**Fix:** In any GraphQL query using searchIssues:

```graphql
# WRONG
searchIssues(query: $query, first: 10)

# CORRECT
searchIssues(term: $term, first: 10)
```

---

### Issue: Workflow Succeeds But No Issues Created

**Check 1:** Lifelogs already processed

```bash
cat ~/Repos/experiments/assistant/data/sync-state.json | jq '.processedLifelogIds | length'
```

If IDs are present, the pipeline skipped them. Reset state to reprocess.

**Check 2:** No action items extracted

Check workflow logs:
```bash
gh run view <RUN_ID> -R Sohailm25/assistant --log 2>/dev/null | grep -i "action items"
```

If "0 action items" or no matches, the meeting transcript didn't contain actionable tasks.

**Check 3:** No lifelogs for that date

```bash
# Query Limitless directly
curl -s "https://api.limitless.ai/v1/lifelogs?date=$(date +%Y-%m-%d)&timezone=America/Chicago&limit=10" \
  -H "X-API-Key: $LIMITLESS_API_KEY" | jq '.data.lifelogs | length'
```

---

### Issue: Duplicate Issues Being Created

**Symptom:** Same action item creates multiple Linear issues

**Root Cause:** Deduplication uses title matching. If titles differ slightly, duplicates occur.

**Check:** Search Linear for similar issues:
```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query { searchIssues(term: \"PARTIAL_TITLE\", first: 10) { nodes { identifier title } } }"
  }' | jq '.data.searchIssues.nodes'
```

---

### Issue: Git Conflicts on Sync State

**Symptom:** Push fails due to sync-state.json conflicts

**Cause:** GitHub Actions committed state while you were editing locally

**Fix:**
```bash
cd ~/Repos/experiments/assistant
git pull --rebase
# Resolve conflicts if any, keeping the newer state
git push
```

---

## Verify Linear Configuration

```bash
# Check config
cat ~/Repos/experiments/assistant/data/config.json | jq '.linear'

# Should show:
# {
#   "apiToken": "lin_api_...",
#   "teamId": "uuid",
#   "doneStateId": "uuid"
# }
```

---

## Manual Pipeline Test

Run the pipeline locally (requires API keys in environment):

```bash
cd ~/Repos/experiments/assistant
source .venv/bin/activate  # if using venv

export LIMITLESS_API_KEY="..."
export ANTHROPIC_API_KEY="..."
export LINEAR_API_KEY="..."

python -m src.main process --date 2025-12-29
```
