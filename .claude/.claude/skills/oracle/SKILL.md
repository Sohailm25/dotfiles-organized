---
name: oracle
description: Deep research and reasoning using GPT Pro. Use for complex questions requiring extensive research, architectural decisions, or when you need a second opinion on difficult problems.
allowed-tools: Bash,Read
---

# Oracle (GPT Pro Research)

External research tool using GPT Pro for deep reasoning and research.

**Preference**: Always use `--engine browser` flag first (no API key needed). Ask permission if API key required.

---

## Usage

```bash
# Browser mode (preferred, no API key)
npx -y @steipete/oracle -p "your prompt" --engine browser --file docs/file1.md docs/file2.md

# API mode (when browser insufficient)
OPENAI_API_KEY=sk-... npx -y @steipete/oracle -p "prompt" --file docs/file1.md
```

## Parameters

| Flag | Purpose |
|------|---------|
| `-p` | Query/prompt |
| `--file` | Context files essential for proper answers |
| `--engine browser` | Use browser instead of API key (cost effective) |

---

## Best Practices

- Always pass in PRD file when relevant
- Think deeply about all context needed for proper answers
- When using `--engine browser`, do NOT use OPENAI_API_KEY
- Use for research until 100% confident in findings

---

## API Key (when needed)

Use `OPENAI_API_KEY` from `~/.dotfiles-secrets` or environment.
