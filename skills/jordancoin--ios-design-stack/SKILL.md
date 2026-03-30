---
name: ios-design-stack
description: >
  Invocable iOS design pipeline. When called with a design prompt, runs an autonomous
  loop: designs iOS screens in Pencil MCP following Apple HIG, reviews for taste using
  Design Philosophy, validates with XcodeBuildMCP, and iterates until done.
  Use as: /ios-design-stack "Design a [screen] for [app] with [requirements]"
user-invocable: true
argument-hint: "Design a [screen] for [app]"
---

# /ios-design-stack

Autonomous iOS design pipeline. Give it a prompt, it designs, reviews, builds, and
iterates until the result passes both taste and build checks.

## When Invoked

Parse the user's prompt as the **design brief**. Then run this pipeline as a loop
until the design passes all checks.

## Pipeline

```
┌─────────────────────────────────────────────────┐
│  1. SETUP     Load tokens + guidelines          │
│  2. DESIGN    Create screen in Pencil MCP       │
│  3. REVIEW    Taste-check with Design Philosophy│
│  4. BUILD     Export SwiftUI, build, screenshot  │
│  5. VERIFY    Compare screenshot to design       │
│  6. ITERATE   Fix issues, loop to step 2         │
│  7. DONE      All checks pass                    │
└─────────────────────────────────────────────────┘
```

## Step 1: Setup

Load the iOS design skills in this repo:

```
Read: skills/ios-design-tokens/SKILL.md     ← iOS HIG tokens (colors, type, spacing)
Read: skills/pencil-ios-design/SKILL.md     ← Pencil MCP iOS workflow
Read: skills/design-philosophy/SKILL.md     ← taste principles
```

Then initialize:

1. Call `get_editor_state` to check Pencil MCP is available
2. Call `open_document("new")` or open existing .pen file
3. Call `set_variables` with iOS design tokens from `ios-design-tokens` skill
4. Call `get_guidelines(topic="mobile-app")` for Apple HIG rules

If the user specified an aesthetic (e.g., "dark, minimal, premium"):
5. Call `get_style_guide_tags` then `get_style_guide(tags=[...])` to get style direction

## Step 2: Design

Using the `pencil-ios-design` skill as your guide:

1. Call `find_empty_space_on_canvas(width=393, height=852)` for iPhone 15 Pro frame size
2. Call `batch_design` to create the screen layout. Max 25 operations per call.

**Mandatory iOS rules:**
- 59pt top safe area (Dynamic Island)
- 34pt bottom safe area (home indicator)
- 16-20pt horizontal margins
- All touch targets ≥ 44x44pt
- 8pt spacing grid
- SF Pro typography only, using iOS type scale
- iOS semantic colors only (not hardcoded hex)
- Continuous corners (squircle)

Refer to the common screen patterns in `pencil-ios-design` for Login, Settings,
Detail, and other standard layouts.

## Step 3: Review (Design Philosophy)

Before building, taste-check the design. Ask these questions:

1. **What's the one feeling this creates?** Write it in one word.
2. **What would you remove?** Cut at least one element.
3. **Does every element earn its place?** If removing it changes nothing, remove it.
4. **Would Apple ship this?** Be honest.

From the Design Philosophy skill:
- Typography creates hierarchy, not color or weight
- Whitespace = premium. Cramped = cheap.
- One focal point per screen
- One accent color maximum
- Less, but better. (Dieter Rams #10)

**If the design fails taste review**, go back to Step 2 and simplify.
Do NOT proceed to build until taste passes.

## Step 4: Build

Export the design and validate it compiles:

1. Export the Pencil design nodes to SwiftUI code
2. Create/update the Swift file in the project
3. Build with XcodeBuildMCP: `xcodebuild build`
4. Run in simulator: `xcrun simctl boot` + install + launch
5. Capture screenshot: `xcodebuildmcp screenshot`

If XcodeBuildMCP is not available, skip to Step 5 with the Pencil screenshot only.

## Step 5: Verify

Compare the build screenshot (or Pencil screenshot) against the design:

```
Call: get_screenshot(nodeId="frame-id")
Call: snapshot_layout(nodeId="frame-id", problemsOnly=true)
Call: search_all_unique_properties(nodeId="frame-id", properties=["fillColor", "fontFamily", "fontSize"])
```

**Verification checklist:**
- [ ] Spacing follows 8pt grid
- [ ] All touch targets ≥ 44pt
- [ ] Typography hierarchy is clear (squint test passes)
- [ ] One focal point dominates the screen
- [ ] Only SF Pro font family used
- [ ] Only iOS type scale sizes (11, 12, 13, 15, 16, 17, 20, 22, 28, 34)
- [ ] Only semantic colors (no random hex)
- [ ] Continuous corners, not circular
- [ ] Safe areas respected (top 59pt, bottom 34pt)
- [ ] No layout issues (snapshot_layout reports clean)
- [ ] Code compiles without warnings (if built)
- [ ] Screenshot matches design intent

## Step 6: Iterate

If any checks fail:

1. Identify the specific issue
2. Fix it in the Pencil design (batch_design update operations)
3. Re-verify (back to Step 5)
4. If it's a taste issue, revisit Step 3
5. If it's a build issue, revisit Step 4

Continue iterating until ALL checks pass.

## Step 7: Done

When all checks pass, report:

```
DESIGN COMPLETE

Screen: [name]
Feeling: [one word]
Checks passed:
  ✓ Typography: SF Pro, iOS type scale
  ✓ Spacing: 8pt grid
  ✓ Colors: iOS semantic tokens
  ✓ Touch targets: ≥ 44pt
  ✓ Safe areas: respected
  ✓ Taste: [one sentence on why it passes]
  ✓ Build: compiles, zero warnings
  ✓ Screenshot: matches design intent

Files:
  - [.pen file path]
  - [.swift file path]
```

## Using with Ralph Loop

For fully autonomous iteration, wrap this skill in a Ralph Loop:

```
/ralph-loop "Run /ios-design-stack with this brief:

[USER'S DESIGN BRIEF HERE]

Success criteria:
- Design passes all verification checks
- Code compiles without warnings
- Screenshot matches design intent
- Taste check passes (would Apple ship this?)

Output <promise>DESIGN_COMPLETE</promise> when all checks pass." --max-iterations 15
```

The Ralph Loop will keep re-running the pipeline until it converges on a design
that passes every check. Typical: 3-5 iterations for a simple screen.

## External Dependencies

| Tool | Source | Required? |
|------|--------|-----------|
| Pencil MCP | pencil.dev | **Yes** — the design canvas |
| XcodeBuildMCP | [getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP) | Optional — for build validation |
| Ralph Loop | [anthropics/claude-code](https://github.com/anthropics/claude-code) | Optional — for autonomous iteration |

## Skills in This Repo

| Skill | What it does |
|-------|-------------|
| `skills/design-philosophy/` | Taste principles — Dieter Rams, "less but better" |
| `skills/ios-design-tokens/` | iOS HIG tokens — typography, colors, spacing, radii |
| `skills/pencil-ios-design/` | iOS Pencil MCP workflow — how to design iOS screens |
