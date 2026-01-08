---
name: morph-mcp
description: Fast file editing and code search. Use for quick edits, searching across files, or when you need faster file operations than standard read/write.
allowed-tools: Bash,Read
---

# morph-mcp

Fast file editing tool with intelligent code search.

**Command**: `npx -y @morphllm/morphmcp`

---

## Key Features

### warp-grep
Surfaces relevant context across files. **Use FIRST when understanding code.**

### edit_file
Much faster than reading + writing entire files.

---

## Best Practices

1. **Minimize edit scope**: Include only sections that need changes
2. **Batch related edits**: Make multiple changes in single edit_file call
