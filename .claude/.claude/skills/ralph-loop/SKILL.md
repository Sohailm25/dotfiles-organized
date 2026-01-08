---
name: ralph-loop
description: Autonomous iteration loops for mechanical batch tasks. Use when user mentions "ralph", "autonomous loop", "overnight", "batch refactor", "run until done", or describes large mechanical tasks with clear completion criteria (migrations, test coverage, documentation generation, file transformations).
allowed-tools: Bash,Read,Glob,Write
---

# Ralph Loop Skill - Autonomous Development Loops

Use the ralph-wiggum plugin for tasks that benefit from iterative, autonomous execution.

## When to Surface This Skill

**TRIGGER PHRASES:**
- "ralph loop", "ralph", "autonomous loop"
- "overnight task", "walk away", "run until done"
- "batch refactor", "migrate all", "transform all files"
- "add tests to all", "document all functions"
- "keep trying until it works"

**TASK CHARACTERISTICS (suggest ralph-loop when ALL apply):**
1. Clear, mechanical transformation (not creative/design work)
2. Definable completion criteria (tests pass, files match pattern, etc.)
3. Multiple files/iterations expected
4. Automatic verification possible (build succeeds, linter passes, tests green)

**DO NOT SUGGEST for:**
- Architectural decisions or design work
- Security-sensitive code (auth, payments, data handling)
- Debugging production issues
- Tasks requiring human judgment between steps
- Unclear or ambiguous requirements

---

## Command Syntax

```bash
/ralph-loop "PROMPT" --max-iterations N --completion-promise "PHRASE"
```

### Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `PROMPT` | Yes | - | Task description (quote if multi-word) |
| `--max-iterations` | Recommended | unlimited | Safety limit to prevent runaway loops |
| `--completion-promise` | Optional | none | Exact phrase Claude outputs when done |

---

## Prompt Structure

```markdown
TASK: [One sentence describing what to do]

SUCCESS CRITERIA:
- [Specific, verifiable condition 1]
- [Specific, verifiable condition 2]

VERIFICATION:
- Run: [command to check success]
- Expected: [what success looks like]

When ALL criteria are met, output: <promise>COMPLETE</promise>
```

### Example

```bash
/ralph-loop "Add unit tests for all exported functions in src/processing/. 
Use vitest. Each function needs at least 2 test cases. 
Run 'bun test' after each change.
When all tests pass, output <promise>TESTS COMPLETE</promise>" \
  --max-iterations 30 \
  --completion-promise "TESTS COMPLETE"
```

---

## Monitoring & Control

```bash
# Check current iteration
grep '^iteration:' .claude/ralph-loop.local.md

# View full state
cat .claude/ralph-loop.local.md

# Cancel active loop
/cancel-ralph

# Or manually
rm .claude/ralph-loop.local.md
```

---

## How It Works

1. `/ralph-loop` creates a state file at `.claude/ralph-loop.local.md`
2. A **Stop Hook** intercepts Claude's exit attempts
3. If completion criteria not met, the SAME prompt is fed back
4. Claude sees its previous work in files and git history
5. Loop continues until `--completion-promise` detected or `--max-iterations` reached

The loop creates a **self-referential feedback loop** where:
- The prompt never changes between iterations
- Claude's previous work persists in files
- Each iteration sees modified files and git history
- Claude autonomously improves by reading its own past work
