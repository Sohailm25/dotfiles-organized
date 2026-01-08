---
name: meetings
description: Query synced Limitless meeting transcripts and notes. Use when the user asks about past meetings, what was discussed, meeting history by date or job. Triggers on questions like "what Amazon meetings this week", "what did we discuss yesterday", "find meetings about X".
allowed-tools: Bash,Read,Glob,Grep
---

# Meetings Query Skill

Query Limitless meeting transcripts synced to `~/Repos/experiments/assistant`.

> **Related Skills:**
> - `limitless` - Live Limitless API queries (real-time data, not yet synced)
> - `standup` - Claude-extracted accomplishments/blockers per job  
> - `workflow` - Trigger sync if data is stale
> - `sync-control` - Check/reset sync state, troubleshooting

## Prerequisites

**ALWAYS execute these steps before any query:**

### Step 1: Pull Latest Data

```bash
cd ~/Repos/experiments/assistant && git pull --ff-only
```

### Step 2: Check Data Freshness

Read the sync state to determine if data is stale:

```bash
cat ~/Repos/experiments/assistant/data/sync-state.json | jq '{lastPollTimestamp, lastSyncDate}'
```

Parse `lastPollTimestamp` and compare to current time. If more than 1 hour old:

**Warn the user:**
```
⚠️ Meeting data was last synced at [TIME]. This may be outdated.
Would you like me to trigger a fresh sync? (Takes ~2-3 minutes)
```

If user agrees, trigger sync (see `workflow` skill):
```bash
gh workflow run daily-sync.yml -R Sohailm25/assistant
```

### Step 3: Load Job Configurations

Read job keywords for classification:

```bash
for f in ~/Repos/experiments/assistant/data/jobs/*.json; do
  echo "=== $(basename $f .json) ==="
  cat "$f" | jq '{keywords, participants}'
done
```

**Job Keywords Reference:**
| Job | Keywords |
|-----|----------|
| amazon | aws, amazon, sde, lambda, s3, ec2, dynamodb, bezos, prime |
| experian | experian, credit |
| britannica | britannica, encyclopedia |
| cvs | cvs, pharmacy |

---

## Directory Structure

```
~/Repos/experiments/assistant/
├── meetings/
│   └── YYYY/
│       └── MM-month/
│           └── week-WW/
│               └── YYYY-MM-DD/
│                   ├── meeting-slug.md
│                   └── daily-summary.md
├── transcripts/
│   └── YYYY-MM-DD/
│       └── {lifelog-id}.md
├── summaries/
│   ├── daily/YYYY-MM-DD.md
│   └── weekly/YYYY-WXX.md
├── standups/           # ← Use `standup` skill for these
│   └── {job}/standup.md
├── debrief/            # ← Use `debrief` skill for these
│   └── YYYY-MM-DD.md
└── data/
    ├── sync-state.json
    └── jobs/*.json
```

---

## Query Patterns

### By Specific Date

```bash
ls ~/Repos/experiments/assistant/meetings/2025/*/week-*/2025-12-28/*.md 2>/dev/null | grep -v daily-summary
```

### By Date Range (This Week)

```bash
# Get current week number
WEEK=$(date +%V)
YEAR=$(date +%Y)

find ~/Repos/experiments/assistant/meetings/$YEAR -path "*week-$WEEK*" -name "*.md" | grep -v daily-summary
```

### By Today

```bash
TODAY=$(date +%Y-%m-%d)
ls ~/Repos/experiments/assistant/meetings/*/*/week-*/$TODAY/*.md 2>/dev/null | grep -v daily-summary
```

### By Keyword/Topic

```bash
grep -rl "SEARCH_TERM" ~/Repos/experiments/assistant/meetings/ --include="*.md" | head -20
```

### By Job

Search for job-specific keywords in meeting content:

```bash
# Example: Find Amazon-related meetings
grep -rl -E "(amazon|aws|lambda|s3|ec2)" ~/Repos/experiments/assistant/meetings/ --include="*.md" | head -20
```

### Raw Transcripts

```bash
ls ~/Repos/experiments/assistant/transcripts/2025-12-28/*.md
```

---

## Job Classification

When classifying meetings by job:

1. **Parse YAML frontmatter** - Check `tags` field for job keywords
2. **Search title** - Look for job keywords in meeting title
3. **Search content** - Grep for job keywords in body

### Handling Multiple Matches

If a meeting matches keywords for multiple jobs, **ask the user to clarify**:

```
This meeting mentions both Amazon (aws, lambda) and Experian (credit check).
Which job context are you interested in?
1. Amazon
2. Experian
3. Both
```

### Reading Meeting Metadata

```bash
# Extract YAML frontmatter
head -30 "path/to/meeting.md" | sed -n '/^---$/,/^---$/p'
```

---

## Response Guidelines

### DO:
- Summarize findings intelligently based on query intent
- Include meeting dates and titles in responses
- Highlight relevant excerpts when searching by topic
- Group results by job if querying across multiple jobs
- Mention total count when returning partial results

### DON'T:
- Dump raw file contents without synthesis
- Return more than 5-10 meetings without summarizing
- Assume job context without checking keywords
- Skip the staleness check

### Response Format Examples

**For "what Amazon meetings this week":**
```
Found 3 Amazon-related meetings this week:

1. **Design Review: Auth Service** (Dec 26, Thu)
   - Discussed Lambda authorization patterns
   - Action: Update IAM policies by Friday

2. **1:1 with Manager** (Dec 27, Fri)
   - Career growth discussion
   - Follow-up: Schedule skip-level

3. **Sprint Planning** (Dec 28, Sat)
   - Q1 roadmap review
   - Committed to 3 stories
```

**For "what did we discuss about X":**
```
Found 2 mentions of "X" in recent meetings:

**Meeting: Project Kickoff** (Dec 25)
> "We need to finalize the X integration by end of month..."

**Meeting: Tech Sync** (Dec 26)  
> "The X dependency is blocking the frontend work..."
```

---

## Common Workflows

### "What did I accomplish at Amazon this week?"

Use the `standup` skill instead - it shows Claude-extracted accomplishments from meeting transcripts:
```bash
head -80 ~/Repos/experiments/assistant/standups/amazon/standup.md
```

### "Search for something said in a meeting"

For synced data (this skill):
```bash
grep -rl "search term" ~/Repos/experiments/assistant/meetings/ --include="*.md"
```

For live API search (use `limitless` skill):
```bash
curl -s "https://api.limitless.ai/v1/lifelogs?search=QUERY&timezone=America/Chicago" \
  -H "X-API-Key: $LIMITLESS_API_KEY"
```

---

## Trigger Manual Sync

When data is stale or user requests fresh data (see `workflow` skill for details):

```bash
gh workflow run daily-sync.yml -R Sohailm25/assistant
```

Check workflow status:
```bash
gh run list --workflow=daily-sync.yml -R Sohailm25/assistant --limit=1
```

Wait for completion:
```bash
gh run watch $(gh run list --workflow=daily-sync.yml -R Sohailm25/assistant --limit=1 --json databaseId -q '.[0].databaseId')
```

Then pull latest:
```bash
git pull --ff-only
```
