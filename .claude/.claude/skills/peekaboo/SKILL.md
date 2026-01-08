---
name: peekaboo
description: macOS GUI automation, screenshots, and AI vision analysis. Use for capturing screenshots, analyzing UI, automating clicks/typing, managing windows, or interacting with desktop applications.
allowed-tools: Bash,Read
---

# Peekaboo

macOS utility for screenshots, AI vision analysis, and GUI automation.

**Help**: `peekaboo command --help` for inline summaries

---

## Vision & Capture

| Command | Purpose |
|---------|---------|
| `see` | Capture annotated UI maps, produce session IDs, optional inline analysis |
| `image` | Raw PNG/JPG screenshots (screens, windows, menu bar) with `--analyze` for AI |

---

## Core Utilities

| Command | Purpose |
|---------|---------|
| `list` | Subcommands: apps, windows, screens, menubar, permissions |
| `tools` | Enumerate native + MCP tools; filter by server/source |
| `config` | Subcommands: init, show, add, login, set-credential, models |
| `permissions` | Status and grant helpers for Screen Recording, Accessibility |
| `learn` | Emit full agent guide/system prompt |
| `run` | Execute .peekaboo.json automation scripts |
| `sleep` | Millisecond delays between scripted steps |
| `clean` | Prune session caches |

---

## Interaction

| Command | Purpose |
|---------|---------|
| `click` | Element IDs, fuzzy queries, or coordinates with wait/focus helpers |
| `type` | Text + escape sequences, --clear, tab/return/escape/delete flags |
| `press` | Special key sequences with repeat counts |
| `hotkey` | Modifier combos (cmd,shift,t) |
| `scroll` | Directional scrolls with optional element targets |
| `swipe` | Smooth drags between IDs or coordinates |
| `drag` | Drag-and-drop with modifiers, Dock/Trash targets |
| `move` | Cursor placement (coords, element IDs, queries, screen center) |

---

## Windows, Menus, Apps & Spaces

| Command | Purpose |
|---------|---------|
| `window` | close, minimize, maximize, move, resize, set-bounds, focus, list |
| `menu` | click, click-extra, list, list-all for app menus and menu extras |
| `menubar` | list/click status-bar items by name or index |
| `app` | launch, quit, relaunch, hide, unhide, switch, list |
| `open` | macOS-style open with focus/failure handling |
| `dock` | launch, right-click, hide, show, list |
| `dialog` | click, input, file, dismiss, list system dialogs |
| `space` | list, switch, move-window (Spaces/virtual desktops) |

---

## Agents & Integrations

| Command | Purpose |
|---------|---------|
| `agent` | Natural-language automation (--dry-run, --resume, --model, audio, session caching) |
| `mcp` | serve, list, add, remove, enable, disable, info, test, call, inspect |
