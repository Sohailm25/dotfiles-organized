---
name: skylight
description: Skylight Calendar tasks, chores, and lists management
homepage: https://ourskylight.com
metadata: {"clawdis":{"emoji":"📋"}}
---

# skylight

Manage tasks, chores, and lists on Skylight Calendar.

## Setup

Configure in `~/.clawdis/clawdis.json`:
```json
{
  "skills": {
    "entries": {
      "skylight": {
        "email": "your@email.com",
        "password": "your_password"
      }
    }
  }
}
```

## Commands

### Chores (assigned tasks with dates)
```bash
# List today's chores
skylight chores list

# List chores for a date range
skylight chores list --from 2026-01-01 --to 2026-01-07

# Add a chore
skylight chores add "Take out trash" --date 2026-01-05
skylight chores add "Clean room" --date 2026-01-05 --assignee "Maha" --points 10
```

### Lists (shopping lists, todo lists)
```bash
# Show all lists
skylight lists

# Show items in a list
skylight lists show "Grocery List"

# Add item to a list
skylight lists add "Grocery List" "Milk"
skylight lists add "Grocery List" "Eggs"
```

### Quick add (smart parsing)
```bash
# Adds to default list or as chore depending on content
skylight add "Buy groceries"
skylight add "Take out trash tomorrow"
```

## Notes

- Chores appear on the Skylight Chores tab with optional point rewards
- Lists appear on the Lists tab (shopping lists, etc.)
- Calendar events should still use `gog calendar` (syncs to Skylight automatically)
