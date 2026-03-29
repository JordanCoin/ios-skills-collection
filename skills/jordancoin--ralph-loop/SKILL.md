---
name: ralph-loop
description: Autonomous AI iteration loop for Claude Code. Agent works on a task repeatedly until completion, using a Stop hook to intercept exits. Use for well-defined tasks with clear success criteria.
---

# Ralph Loop

Implementation of the Ralph Wiggum technique for iterative, self-referential AI development loops.

Source: [anthropics/claude-code/plugins/ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)

## What is Ralph?

Ralph is a development methodology based on continuous AI agent loops. As Geoffrey Huntley describes it: **"Ralph is a Bash loop"** — a simple `while true` that repeatedly feeds an AI agent a prompt file, allowing it to iteratively improve its work until completion.

Named after Ralph Wiggum from The Simpsons, embodying persistent iteration despite setbacks.

## How It Works

The plugin uses a **Stop hook** that intercepts Claude's exit attempts:

```bash
# You run ONCE:
/ralph-loop "Your task description" --completion-promise "DONE"

# Then Claude Code automatically:
# 1. Works on the task
# 2. Tries to exit
# 3. Stop hook blocks exit
# 4. Stop hook feeds the SAME prompt back
# 5. Repeat until completion
```

This creates a **self-referential feedback loop** where:
- The prompt never changes between iterations
- Claude's previous work persists in files
- Each iteration sees modified files and git history
- Claude autonomously improves by reading its own past work

## Commands

### /ralph-loop

Start a Ralph loop in your current session.

```bash
/ralph-loop "<prompt>" --max-iterations <n> --completion-promise "<text>"
```

**Options:**
- `--max-iterations <n>` — Stop after N iterations (default: unlimited)
- `--completion-promise <text>` — Phrase that signals completion

### /cancel-ralph

Cancel the active Ralph loop.

## Prompt Writing Best Practices

### 1. Clear Completion Criteria

❌ Bad: "Build a todo API and make it good."

✅ Good:
```markdown
Build a REST API for todos.

When complete:
- All CRUD endpoints working
- Input validation in place
- Tests passing (coverage > 80%)
- README with API docs
- Output: <promise>COMPLETE</promise>
```

### 2. Incremental Goals

❌ Bad: "Create a complete e-commerce platform."

✅ Good:
```markdown
Phase 1: User authentication (JWT, tests)
Phase 2: Product catalog (list/search, tests)
Phase 3: Shopping cart (add/remove, tests)

Output <promise>COMPLETE</promise> when all phases done.
```

### 3. Self-Correction via TDD

```markdown
Implement feature X following TDD:
1. Write failing tests
2. Implement feature
3. Run tests
4. If any fail, debug and fix
5. Refactor if needed
6. Repeat until all green
7. Output: <promise>COMPLETE</promise>
```

### 4. Always Set Max Iterations

```bash
# Safety net to prevent infinite loops
/ralph-loop "Try to implement feature X" --max-iterations 20
```

In your prompt, include what to do if stuck:
```
After 15 iterations, if not complete:
- Document what's blocking progress
- List what was attempted
- Suggest alternative approaches
```

## When to Use Ralph

**Good for:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration and refinement (tests to pass)
- Greenfield projects where you can walk away
- Tasks with automatic verification (tests, linters, screenshots)

**Not good for:**
- Tasks requiring human judgment or design decisions
- One-shot operations
- Tasks with unclear success criteria
- Production debugging

## Philosophy

1. **Iteration > Perfection** — Don't aim for perfect on first try
2. **Failures Are Data** — "Deterministically bad" failures are predictable and informative
3. **Operator Skill Matters** — Success depends on good prompts, not just good models
4. **Persistence Wins** — Keep trying until success

## Real-World Results

- 6 repos generated overnight (Y Combinator hackathon)
- One $50k contract completed for $297 in API costs
- Entire programming language built over 3 months

## iOS Design Example

```bash
/ralph-loop "Design and implement a login screen for iOS.

Use Pencil MCP to design the UI.
Use XcodeBuildMCP to build and screenshot.

Requirements:
- Follow Apple HIG
- Clean, minimal, premium feel
- Accessible (Dynamic Type, VoiceOver labels)
- Dark mode support
- Code compiles without warnings

Verification:
1. Export SwiftUI from Pencil
2. Build with xcodebuildmcp
3. Screenshot the result
4. Compare to design philosophy guidelines

Output <promise>COMPLETE</promise> when:
- Design is visually polished
- Code compiles cleanly
- Screenshot matches intent" --max-iterations 20 --completion-promise "COMPLETE"
```

## Resources

- Original technique: https://ghuntley.com/ralph/
- Ralph Orchestrator: https://github.com/mikeyobrien/ralph-orchestrator
- Claude Code plugins: https://github.com/anthropics/claude-code/tree/main/plugins
