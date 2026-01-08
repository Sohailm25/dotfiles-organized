# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- home-server → 192.168.1.100, user: admin

### TTS
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Google Calendar (gog)

Account: `sohailm25@gmail.com`

### Calendars
- **M&S - The Dream** (shared with Maha): `0aac28aefc01f37e5cc81b315722d3171676e3b9d4999608f10d3f80c4ab4e7b@group.calendar.google.com`

### Commands
```bash
# List events
gog calendar events "0aac28aefc01f37e5cc81b315722d3171676e3b9d4999608f10d3f80c4ab4e7b@group.calendar.google.com" --account sohailm25@gmail.com --from "2026-01-03" --to "2026-01-10"

# Create event
gog calendar create "0aac28aefc01f37e5cc81b315722d3171676e3b9d4999608f10d3f80c4ab4e7b@group.calendar.google.com" \
  --account sohailm25@gmail.com \
  --summary "Event Title" \
  --from "2026-01-04T10:00:00-06:00" \
  --to "2026-01-04T11:00:00-06:00" \
  --description "Description" \
  --force

# All-day event
gog calendar create "..." --all-day --from "2026-01-05" --to "2026-01-05" --summary "All Day Thing" --force
```

### Users
- Sohail: sohailm25@gmail.com
- Maha: mahanadeem273@gmail.com

---

## Telegram

- Bot: @sohails_ghost_bot
- Group chat ID: -5205577772 (M&S group with Sohail + Maha)
- Sohail ID: 1021616650
- Maha ID: 8588074404

---

## Skylight Calendar (Tasks & Chores)

For calendar events, use `gog` (syncs to Skylight automatically).
For tasks, chores, and lists, use `skylight`:

### Chores (assigned tasks with due dates)
```bash
# List today's chores
~/.clawdis/skills/skylight/skylight.mjs chores list

# Add a chore for today
~/.clawdis/skills/skylight/skylight.mjs chores add "Take out trash"

# Add a chore for a specific date
~/.clawdis/skills/skylight/skylight.mjs chores add "Clean kitchen" --date 2026-01-05

# Add with assignee and reward points
~/.clawdis/skills/skylight/skylight.mjs chores add "Do laundry" --date tomorrow --assignee "Maha" --points 10
```

### Lists (shopping lists, todo lists)
```bash
# Show all lists
~/.clawdis/skills/skylight/skylight.mjs lists

# Show items in a specific list
~/.clawdis/skills/skylight/skylight.mjs lists show "Grocery List"

# Add item to a list
~/.clawdis/skills/skylight/skylight.mjs lists add "Grocery List" "Milk"
```

### Family Members
```bash
# List family members (for --assignee)
~/.clawdis/skills/skylight/skylight.mjs categories
```

### When to use what
- **Calendar event** (has a specific time): Use `gog calendar create`
- **Chore** (task with due date, optional assignee): Use `skylight chores add`
- **List item** (shopping/todo list): Use `skylight lists add`

---

Add whatever helps you do your job. This is your cheat sheet.
