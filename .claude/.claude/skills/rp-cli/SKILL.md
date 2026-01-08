---
name: rp-cli
description: Codebase context management with RepoPrompt. Use for building file context, managing selections, coordinating with external models, exploring code structure, or pair programming workflows.
allowed-tools: Bash,Read,Glob
---

# rp-cli (RepoPrompt)

Master tool for codebase context management. Build optimal file context for tasks, manage selections, coordinate with external models.

**Command**: `/Users/sohailmo/RepoPrompt/repoprompt_cli`

```bash
rp-cli -l              # List tools
rp-cli -e 'command'    # Execute command
rp-cli -i              # Interactive REPL
```

---

## Context Building (Use First)

### context_builder
Intelligently explore codebase and build optimal file context for a task.

**Response types:**
- `clarify` (default): Context-only—returns file selection and prompt for you to use
- `question`: Answers a question about the codebase
- `plan`: Generates implementation plan

Takes 30s-5min depending on codebase size. Continue via `chat_send` with returned `chat_id`.

### workspace_context
Snapshot of workspace: prompt, selection, code structure (codemaps).

**Include options**: prompt, selection, code, files, tree, tokens
**Path display**: relative | full

---

## Selection Management

### manage_selection
Manage current selection used by all tools.

**Operations:**
| Op | Purpose |
|----|---------|
| `get` | View current selection |
| `add` | Add paths to selection |
| `remove` | Remove paths |
| `set` | Replace entire selection |
| `clear` | Clear all |
| `preview` | Preview changes before committing |
| `promote` | Convert codemap to full content |
| `demote` | Convert full content to codemap |

**Views**: summary (default), files (with token counts), content (full)

**Modes:**
- `full`: Complete file content (default)
- `slices`: Specific line ranges only
- `codemap_only`: Function/type signatures for token savings

**Examples:**
```json
{"op":"add","paths":["src/main.swift"]}
{"op":"add","paths":["src/utils/helper.swift"],"mode":"codemap_only"}
{"op":"set","mode":"slices","slices":[{"path":"src/file.swift","ranges":[{"start_line":45,"end_line":120,"description":"UserAuth flow"}]}]}
{"op":"promote","paths":["src/utils/helper.swift"]}
```

### prompt
Get or modify shared prompt (instructions/notes).

**Operations**: get | set | append | clear

---

## Exploration

### get_file_tree
ASCII directory tree of project.

**Modes:**
- `auto` (default): Tries full tree, trims depth to fit ~10k tokens
- `full`: All files/folders (can be large)
- `folders`: Directories only
- `selected`: Only selected files and parents

Files with codemap marked with `+` in tree.

### get_code_structure
Return code structure (codemaps) for files and directories.

**Scopes:**
- `selected`: Structures for current selection
- `paths` (default): Pass specific paths (directories recursive)

### file_search
Search by file path and/or content.

**Defaults**: regex=true, case-insensitive, max_results=50
**Modes**: auto | path | content | both

```json
{"pattern":"frame(minWidth:", "regex":false}     // Literal
{"pattern":"performSearch|searchUsers", "regex":true}  // Regex OR
{"pattern":"*.swift", "mode":"path"}             // Path glob
```

### read_file
Read file contents with optional line range.

- `start_line`: Positive for line number, negative for tail -n
- `limit`: Number of lines (only with positive start_line)

---

## Chat

### chat_send
Start new chat or continue existing conversation.

**Modes**: chat | plan | edit

**Params:**
- `new_chat`: true to start new, else continues most recent
- `chat_id`: Specific chat to continue
- `selected_paths`: Replace selection for this message
- `chat_name`: Short, descriptive name (recommended)
- `model`: Preset id/name from list_models

**Limitations:**
- No commands/tests—only sees selected files + conversation history
- Does not track diff history—sees current file state only

### chats
List chats or view chat history.

**Actions:**
- `list`: Recent chats (ID, name, selected files, last activity)
- `log`: Full conversation history (optionally with diffs)

### list_models
List available model presets. Use before chat_send to pick appropriate preset.

---

## File Operations

### apply_edits
Apply direct file edits (rewrite or search/replace).

**Modes:**
```json
// Replacement
{"path": "file.swift", "search": "old", "replace": "new", "all": true}

// Multiple edits
{"path": "file.swift", "edits": [{"search": "old1", "replace": "new1"}, ...]}

// Rewrite entire file
{"path": "file.swift", "rewrite": "complete content...", "on_missing": "create"}
```

**Options:**
- `verbose`: Show diff
- `on_missing`: error | create (for rewrite)

### file_actions
Create, delete, or move files.

**Actions:**
- `create`: Create new file with content
- `delete`: Delete file (absolute path required)
- `move`: Move/rename to new_path

---

## Workspace Management

### manage_workspaces
Manage workspaces across RepoPrompt windows.

**Actions**: list | switch | create | delete | add_folder | remove_folder | list_tabs | select_tab

Use `select_tab` to bind connection to specific compose tab for stable context.

---

## Workflows

### Task Initialization
1. Run `context_builder` FIRST for complex tasks
2. Verify with `manage_selection op="get" view="files"` to confirm selection and tokens
3. Refine selection as new areas become relevant

### Pair Programming Loop
1. **Plan**: Use `mode="plan"` for architecture/steps or request review
2. **Apply**: Use `apply_edits` or `chat_send` with `mode="edit"`
3. **Review**: Use `mode="chat"` or `"plan"` for second opinion
4. **Repeat**: Continue in SAME chat for context continuity

### Context Hygiene
- Run `manage_selection op="get" view="files"` before major operations
- Use set/add/remove to ensure ALL related files included
- Use `read_file` before slicing to identify relevant sections
- Preview with `op="preview"` before committing selection changes

### Automatic Codemap
When selecting files with mode="full" or "slices", auto-adds codemaps for related/dependency files. Use `op="get" view="files"` to see complete selection including auto-codemaps.

**Philosophy**: Bias toward MORE context over too little—insufficient context causes more errors than excess.
