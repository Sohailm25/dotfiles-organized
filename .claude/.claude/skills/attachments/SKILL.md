---
name: attachments
description: Attach rich content (PRDs, code, docs, meeting notes) to Linear issues via GitHub Gists. Use when content exceeds 50 lines, contains code blocks, or is a formal document. Triggered by "attach", "add PRD", "add implementation", "add document" + issue reference.
allowed-tools: Bash,Read,Glob,Write
---

# Attachments Skill

Attach rich content to Linear issues using GitHub Gists as the storage layer.

> **When to Use:** Content >50 lines, code implementations, PRDs, meeting notes, 
> or any formal document that deserves version history and clean rendering.

> **Why Gists?** Linear descriptions have rendering limits. Gists provide:
> - Full markdown rendering with syntax highlighting
> - Version history (edit tracking)
> - Direct linking and embedding
> - Multi-file support
> - Stable URLs that survive updates

## Prerequisites

- GitHub CLI authenticated: `gh auth status`
- Linear API key in environment: `$LINEAR_API_KEY`
- Config file at `~/.claude/config.json`

---

## File Naming Convention

All gists follow this pattern for traceability:

```
{issue-identifier}-{content-type}-{YYYYMMDD}.{ext}

Examples:
SOH-15-prd-20251228.md
SOH-22-implementation-20251228.py
SOH-23-meeting-notes-20251228.md
SOH-42-architecture-20251228.md
```

**Content types:**

| Type | Description | Extension |
|------|-------------|-----------|
| `prd` | Product Requirements Document | `.md` |
| `implementation` | Code implementation | `.py`, `.ts`, `.go`, etc. |
| `design` | Technical design document | `.md` |
| `architecture` | Architecture documentation | `.md` |
| `meeting-notes` | Meeting notes/transcripts | `.md` |
| `research` | Research findings | `.md` |
| `spec` | Specification document | `.md` |
| `runbook` | Operational runbook | `.md` |
| `doc` | Generic documentation | `.md` |

---

## When to Use Attachments vs. Description

| Scenario | Use Description | Use Gist Attachment |
|----------|----------------|---------------------|
| Short task title + 1-2 sentences | Yes | No |
| Detailed PRD (>50 lines) | No | Yes |
| Code implementation | No | Yes |
| Meeting notes / transcripts | No | Yes |
| Structured data (tables, diagrams) | No | Yes |
| Quick status update | Yes | No |
| Contains code blocks | No | Yes |
| Formal document with sections | No | Yes |

**Rule of thumb**: If content is >50 lines OR contains code blocks OR is a formal document, use Gist attachment.

---

## Core Workflow

### Step 1: Prepare Content File

Write content to a temp file with proper naming:

```bash
# Get current date
DATE=$(date +%Y%m%d)

# Set variables
ISSUE_IDENTIFIER="SOH-15"  # From user input or search
CONTENT_TYPE="prd"          # Detected from context
TITLE="PRD: Feature Name"   # Descriptive title

# Construct filename
FILENAME="${ISSUE_IDENTIFIER}-${CONTENT_TYPE}-${DATE}.md"

# Write content to temp file
cat > "/tmp/${FILENAME}" << 'EOF'
# Your content here
...
EOF

echo "Created: /tmp/${FILENAME}"
```

### Step 2: Create GitHub Gist

```bash
# Public gist (default for documentation)
gh gist create "/tmp/${FILENAME}" \
  --public \
  --desc "${ISSUE_IDENTIFIER}: ${TITLE}"

# Capture the URL
GIST_URL=$(gh gist create "/tmp/${FILENAME}" \
  --public \
  --desc "${ISSUE_IDENTIFIER}: ${TITLE}" 2>&1 | tail -1)

# Private gist (for sensitive content)
gh gist create "/tmp/${FILENAME}" \
  --desc "${ISSUE_IDENTIFIER}: ${TITLE}"
```

### Step 3: Get Linear Issue UUID

If you have the identifier (e.g., SOH-15), get the UUID:

```bash
ISSUE_UUID=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetIssue($id: String!) { issue(id: $id) { id identifier title } }",
    "variables": {"id": "'"${ISSUE_IDENTIFIER}"'"}
  }' | jq -r '.data.issue.id')

echo "Issue UUID: ${ISSUE_UUID}"
```

### Step 4: Attach Gist to Linear Issue

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation AttachmentCreate($input: AttachmentCreateInput!) { attachmentCreate(input: $input) { success attachment { id title url } } }",
    "variables": {
      "input": {
        "issueId": "'"${ISSUE_UUID}"'",
        "title": "'"${TITLE}"'",
        "url": "'"${GIST_URL}"'"
      }
    }
  }'
```

### Step 5: Report Success

```
Attached ${CONTENT_TYPE} to ${ISSUE_IDENTIFIER}

| Item | Link |
|------|------|
| Linear Issue | https://linear.app/.../issue/${ISSUE_IDENTIFIER}/... |
| Gist | ${GIST_URL} |
| Filename | ${FILENAME} |
```

---

## Multi-File Gists

For related files (e.g., code + tests + README):

```bash
# Create multiple files
cat > "/tmp/SOH-42-implementation-20251228.py" << 'EOF'
# Implementation code
EOF

cat > "/tmp/SOH-42-tests-20251228.py" << 'EOF'
# Test code
EOF

cat > "/tmp/SOH-42-readme-20251228.md" << 'EOF'
# README
EOF

# Create multi-file gist
gh gist create \
  "/tmp/SOH-42-implementation-20251228.py" \
  "/tmp/SOH-42-tests-20251228.py" \
  "/tmp/SOH-42-readme-20251228.md" \
  --public \
  --desc "SOH-42: Feature implementation with tests"
```

---

## Content Type Detection

Automatically detect content type from user request:

| User says | Content type | Extension |
|-----------|--------------|-----------|
| "attach PRD", "add PRD", "create PRD" | `prd` | `.md` |
| "attach implementation", "add code", "attach code" | `implementation` | `.py`, `.ts`, etc. |
| "attach design doc", "add design" | `design` | `.md` |
| "attach meeting notes", "add notes" | `meeting-notes` | `.md` |
| "attach architecture", "add arch doc" | `architecture` | `.md` |
| "attach spec", "add specification" | `spec` | `.md` |
| "attach research", "add findings" | `research` | `.md` |
| "attach document", "add doc" | `doc` | `.md` |

---

## Visibility Decision

| Content Type | Default Visibility | Rationale |
|--------------|-------------------|-----------|
| PRD | Public | Shareable, referenceable |
| Implementation | Public | Open source friendly |
| Design | Public | Collaboration |
| Architecture | Public | Team reference |
| Research | Public | Knowledge sharing |
| Spec | Public | Stakeholder access |
| Meeting notes | **Private** | May contain sensitive info |
| Runbook | **Private** | Operational security |

Override with explicit request: "attach privately" or "attach as private gist"

---

## Complete Example: Attach PRD to Issue

```bash
#!/bin/bash
# Full workflow example

# 1. Set variables
ISSUE_IDENTIFIER="SOH-15"
CONTENT_TYPE="prd"
DATE=$(date +%Y%m%d)
FILENAME="${ISSUE_IDENTIFIER}-${CONTENT_TYPE}-${DATE}.md"
TITLE="PRD: Context Graph for PXT myHR"

# 2. Write content to temp file
cat > "/tmp/${FILENAME}" << 'EOF'
# PRD: Context Graph for PXT myHR

## Problem Statement
...

## Solution
...
EOF

# 3. Create public gist and capture URL
GIST_OUTPUT=$(gh gist create "/tmp/${FILENAME}" \
  --public \
  --desc "${ISSUE_IDENTIFIER}: ${TITLE}" 2>&1)
GIST_URL=$(echo "$GIST_OUTPUT" | tail -1)

echo "Created gist: ${GIST_URL}"

# 4. Get Linear issue UUID
ISSUE_UUID=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetIssue($id: String!) { issue(id: $id) { id } }",
    "variables": {"id": "'"${ISSUE_IDENTIFIER}"'"}
  }' | jq -r '.data.issue.id')

echo "Issue UUID: ${ISSUE_UUID}"

# 5. Attach gist to Linear issue
ATTACH_RESULT=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation AttachmentCreate($input: AttachmentCreateInput!) { attachmentCreate(input: $input) { success attachment { id title url } } }",
    "variables": {
      "input": {
        "issueId": "'"${ISSUE_UUID}"'",
        "title": "'"${TITLE}"'",
        "url": "'"${GIST_URL}"'"
      }
    }
  }')

# 6. Check success
SUCCESS=$(echo "$ATTACH_RESULT" | jq -r '.data.attachmentCreate.success')

if [ "$SUCCESS" = "true" ]; then
  echo "Successfully attached ${FILENAME} to ${ISSUE_IDENTIFIER}"
  echo "Gist URL: ${GIST_URL}"
else
  echo "Failed to attach. Gist URL for manual attachment: ${GIST_URL}"
fi
```

---

## Updating Issue Description with Summary

Optionally add a summary + link to the issue description:

```bash
# Get existing description
EXISTING_DESC=$(curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetIssue($id: String!) { issue(id: $id) { description } }",
    "variables": {"id": "'"${ISSUE_UUID}"'"}
  }' | jq -r '.data.issue.description // ""')

# Create new description with attachment section
NEW_DESC="${EXISTING_DESC}

---
## Attachments
- [${TITLE}](${GIST_URL})"

# Update issue description
ESCAPED_DESC=$(echo "$NEW_DESC" | jq -Rs .)

curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d "{
    \"query\": \"mutation UpdateIssue(\$id: String!, \$input: IssueUpdateInput!) { issueUpdate(id: \$id, input: \$input) { success } }\",
    \"variables\": {
      \"id\": \"${ISSUE_UUID}\",
      \"input\": { \"description\": ${ESCAPED_DESC} }
    }
  }"
```

---

## Error Handling

### Gist Creation Fails

```bash
# Check GitHub CLI auth status
gh auth status

# If not authenticated
gh auth login
```

If gist creation fails, report error and do NOT proceed to Linear attachment.

### Linear Attachment Fails

If gist was created but Linear attachment fails:
1. Report the gist URL so user can manually attach
2. Provide the Linear attachment mutation for manual retry

```
[SUCCESS] Gist created: https://gist.github.com/user/abc123
[FAILED] Linear attachment failed: API error

Manual attachment:
1. Open issue in Linear: https://linear.app/.../SOH-15
2. Click "Add attachment" 
3. Paste URL: https://gist.github.com/user/abc123
```

### Issue Not Found

```bash
# Search for similar issues
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query SearchIssues($term: String!) { searchIssues(term: $term, first: 5) { nodes { id identifier title } } }",
    "variables": {"term": "SEARCH_TERM"}
  }'
```

---

## Listing Attachments for an Issue

Get all attachments for an issue:

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "query GetAttachments($id: String!) { issue(id: $id) { attachments { nodes { id title url createdAt } } } }",
    "variables": {"id": "ISSUE_IDENTIFIER_OR_UUID"}
  }'
```

---

## Updating Existing Gists

Gist URLs are stable, so you can update content without breaking Linear attachments:

```bash
# List your gists
gh gist list

# View a gist
gh gist view GIST_ID

# Edit a gist (opens in editor)
gh gist edit GIST_ID

# Add/replace a file in existing gist
gh gist edit GIST_ID --add "/tmp/updated-file.md"
```

---

## Deleting Attachments

### Remove from Linear (keeps gist)

```bash
curl -s -X POST https://api.linear.app/graphql \
  -H "Content-Type: application/json" \
  -H "Authorization: $LINEAR_API_KEY" \
  -d '{
    "query": "mutation AttachmentDelete($id: String!) { attachmentDelete(id: $id) { success } }",
    "variables": {"id": "ATTACHMENT_UUID"}
  }'
```

### Delete Gist Entirely

```bash
gh gist delete GIST_ID
```

---

## Common Workflows

### "Attach PRD to SOH-15"
1. Detect content type: `prd`
2. Generate filename: `SOH-15-prd-20251228.md`
3. Write content to temp file
4. Create public gist
5. Get issue UUID for SOH-15
6. Attach gist to Linear issue
7. Report success with both URLs

### "Add implementation code to task"
1. Identify issue from context
2. Detect content type: `implementation`
3. Detect language for extension (`.py`, `.ts`, etc.)
4. Generate filename: `SOH-42-implementation-20251228.py`
5. Write code to temp file
6. Create public gist
7. Attach to Linear issue

### "Attach meeting notes privately"
1. Detect content type: `meeting-notes`
2. Override visibility: private (user requested)
3. Generate filename: `SOH-33-meeting-notes-20251228.md`
4. Write notes to temp file
5. Create **private** gist
6. Attach to Linear issue
