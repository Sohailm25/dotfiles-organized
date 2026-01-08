---
name: limitless
description: Search and retrieve Limitless recordings and meeting transcripts. Use when the user asks about past meetings, conversations, what was discussed, meeting notes, or wants to find something that was said. Also use for fetching lifelogs by date.
allowed-tools: Bash,Read,Glob
---

# Limitless API Skill

Interact with Limitless API to search and retrieve meeting recordings (lifelogs).

> **Routing Note:**
> - For **synced local data** (faster, offline): Use the `meetings` skill
> - For **live API queries** (real-time, requires API): Use this skill
> - For **extracted accomplishments/blockers**: Use the `standup` skill
> - To **trigger a fresh sync**: Use the `workflow` skill

## Global Configuration

Read `~/.claude/config.json` to get:
- `limitless.timezone` - Timezone for queries (default: America/Chicago)

Example `~/.claude/config.json`:
```json
{
  "limitless": {
    "timezone": "America/Chicago"
  }
}
```

To read config:
```bash
cat ~/.claude/config.json | jq -r '.limitless.timezone // "America/Chicago"'
```

## Global Prerequisites

Set this environment variable (add to `~/.zshrc`):
```bash
export LIMITLESS_API_KEY="your-limitless-api-key"
```

Get your API key from: https://app.limitless.ai (Developer settings)

## API Endpoint

Base URL: `https://api.limitless.ai/v1`

## Base curl Command

```bash
curl -s "https://api.limitless.ai/v1/lifelogs" \
  -H "X-API-Key: $LIMITLESS_API_KEY" \
  -H "Content-Type: application/json"
```

---

## Search Operations

### Search Lifelogs (Semantic + Keyword)

Search across all recordings using hybrid semantic and keyword search:

```bash
curl -s "https://api.limitless.ai/v1/lifelogs?search=SEARCH_QUERY&timezone=America/Chicago&includeMarkdown=true&includeHeadings=true&includeContents=true&limit=10" \
  -H "X-API-Key: $LIMITLESS_API_KEY"
```

Replace `SEARCH_QUERY` with URL-encoded search terms.

### Search with Date Range

Search within a specific date range:

```bash
curl -s "https://api.limitless.ai/v1/lifelogs?search=SEARCH_QUERY&start=2025-01-01&end=2025-01-15&timezone=America/Chicago&includeMarkdown=true&includeContents=true&limit=20" \
  -H "X-API-Key: $LIMITLESS_API_KEY"
```

---

## Fetch Operations

### Fetch Lifelogs for a Specific Date

Get all recordings for a specific date:

```bash
curl -s "https://api.limitless.ai/v1/lifelogs?date=2025-01-15&timezone=America/Chicago&includeMarkdown=true&includeHeadings=true&includeContents=true&limit=10&direction=asc" \
  -H "X-API-Key: $LIMITLESS_API_KEY"
```

### Fetch Single Lifelog by ID

Get a specific recording by its UUID:

```bash
curl -s "https://api.limitless.ai/v1/lifelogs/LIFELOG_UUID?timezone=America/Chicago&includeMarkdown=true&includeHeadings=true&includeContents=true" \
  -H "X-API-Key: $LIMITLESS_API_KEY"
```

---

## Pagination

The API uses cursor-based pagination. Check the response for `meta.lifelogs.nextCursor`.

### First Page

```bash
curl -s "https://api.limitless.ai/v1/lifelogs?date=2025-01-15&timezone=America/Chicago&includeContents=true&limit=10" \
  -H "X-API-Key: $LIMITLESS_API_KEY"
```

### Subsequent Pages

Use the `nextCursor` from the previous response:

```bash
curl -s "https://api.limitless.ai/v1/lifelogs?date=2025-01-15&timezone=America/Chicago&includeContents=true&limit=10&cursor=CURSOR_VALUE" \
  -H "X-API-Key: $LIMITLESS_API_KEY"
```

---

## Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `date` | Specific date (YYYY-MM-DD) | `2025-01-15` |
| `search` | Search query (URL-encoded) | `project%20meeting` |
| `start` | Start date for range | `2025-01-01` |
| `end` | End date for range | `2025-01-15` |
| `timezone` | Timezone for date queries | `America/Chicago` |
| `includeMarkdown` | Include formatted markdown | `true` |
| `includeHeadings` | Include heading nodes | `true` |
| `includeContents` | Include full content nodes | `true` |
| `limit` | Results per page (max 100) | `10` |
| `direction` | Sort direction | `asc` or `desc` |
| `cursor` | Pagination cursor | (from previous response) |

---

## Response Structure

### Lifelog Object

```json
{
  "id": "uuid",
  "title": "Meeting title",
  "markdown": "Full transcript in markdown...",
  "startTime": "2025-01-15T10:00:00Z",
  "endTime": "2025-01-15T11:00:00Z",
  "isStarred": false,
  "updatedAt": "2025-01-15T11:05:00Z",
  "contents": [
    {
      "type": "heading1",
      "content": "Section title",
      "startTime": "2025-01-15T10:00:00Z",
      "children": []
    },
    {
      "type": "blockquote",
      "content": "Speaker said this...",
      "speakerName": "John Doe",
      "speakerIdentifier": "user",
      "startTime": "2025-01-15T10:01:00Z",
      "startOffsetMs": 60000,
      "children": []
    }
  ]
}
```

### Content Node Types

- `heading1`, `heading2`, `heading3` - Section headings
- `blockquote` - Speaker utterances (includes `speakerName`)
- Other types as defined by Limitless

### Pagination Metadata

```json
{
  "meta": {
    "lifelogs": {
      "nextCursor": "cursor_string_or_null",
      "count": 10
    }
  }
}
```

---

## Common Workflows

### Find what was discussed about a topic
1. Search with relevant keywords
2. Parse the markdown or contents for context

### Get all meetings from a specific day
1. Fetch lifelogs for the date
2. Handle pagination if more than 10 results

### Get meeting context for action items
1. Search for keywords related to the action
2. Look at speaker utterances around that time
3. Extract relevant context from the transcript

### Iterate through multiple days
Run the date fetch for each day in the range:
```bash
for date in 2025-01-13 2025-01-14 2025-01-15; do
  curl -s "https://api.limitless.ai/v1/lifelogs?date=$date&timezone=America/Chicago&includeMarkdown=true&limit=50" \
    -H "X-API-Key: $LIMITLESS_API_KEY"
done
```

---

## Rate Limiting

The API has rate limits. If you receive HTTP 429:
- Wait and retry with exponential backoff
- Check response for `retryAfter` field
- Start with 1 second delay, double on each retry

---

## Tips

- Use `includeMarkdown=true` for readable transcripts
- Use `includeContents=true` for structured speaker data
- Filter short recordings (< 5 minutes) as they're often noise
- The `speakerIdentifier: "user"` indicates the Limitless user (Sohail)
