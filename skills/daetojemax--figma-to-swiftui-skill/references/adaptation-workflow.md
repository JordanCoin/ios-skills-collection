# Adaptation Workflow

Guide for adapting existing SwiftUI screens to match updated Figma designs. This workflow replaces the standard "build from scratch" approach when the user asks to update, adapt, or align an existing screen.

## When to Use

Trigger this workflow when:
- The user says "adapt", "update", "align", "match" an existing screen to a Figma design
- The user provides a Figma URL and references an existing view/screen in the codebase
- The task is to modify existing code rather than create new views

## Adaptation Audit Process

### 1. Read the Existing Code

Read the full source of the view being adapted, including:
- The main view file
- Any subcomponents it references (custom views, shared components)
- Related model types to understand available data

Note every element and its properties: spacing, padding, colors, fonts, layout structure, corner radii, opacity values.

### 2. Build a Diff Checklist

Compare the existing code against the Figma design context and screenshot **element by element**. Categorize each difference:

- **ADD** — Element exists in Figma but not in code
- **UPDATE** — Element exists in both but with different properties. Always include old → new values.
- **REMOVE** — Element exists in code but not in Figma. Always confirm with user before removing.

### 3. Spacing Audit

Spacing is the most commonly missed difference. For every container and element, explicitly compare:
- Horizontal and vertical padding values
- Stack spacing values (VStack/HStack spacing parameter)
- Gaps between elements
- Edge insets and safe area handling
- Frame sizes (width, height)

Never assume existing values are "close enough". If Figma says 20 and the code says 16, that is a change that must be listed.

### 4. Present the Checklist

Show the full checklist to the user before writing any code. Use this format:

```
Differences found:

### Structural
- ADD: timer card component (lime background, countdown, progress bar)
- ADD: illustration header with text overlay
- REMOVE: separate winner section — confirm?

### Layout & Spacing
- UPDATE: avatar size 56 → 64
- UPDATE: card spacing (avatar ↔ content) 12 → 8
- UPDATE: bottom padding per card 16 → 24
- UPDATE: divider opacity 0.12 → 0.14

### Typography
- UPDATE: title font 17pt medium → 20pt semibold
- UPDATE: team name font 17pt → 20pt regular
- UPDATE: points font 28pt semibold → 22pt expanded semibold

### Colors & Styling
- UPDATE: place badge — gold/silver/bronze gradients → purple gradient for all
- UPDATE: background gradient — hardcoded RGB → asset catalog colors

### New Data Requirements
- Timer: hardcode or needs API data?
- Stats tags: data source needed?
```

Group changes by category (structural, spacing, typography, colors) so the user can review systematically.

### 5. Clarify Unknowns

Before implementing, ask the user about:
- **New components** that need data not available in current models (e.g., timer, stats)
- **Removed elements** — confirm before deleting
- **Ambiguous elements** — when Figma shows something that could be system-provided or custom

### 6. Apply All Changes

After user confirmation, apply every item from the checklist. Do not skip items that seem minor — a 4px padding difference or a 0.02 opacity change matters for visual fidelity.

## Common Pitfalls

1. **"Close enough" bias** — When existing code looks similar to the design, it's tempting to skip small differences. The checklist prevents this.
2. **Missing new elements** — Focus on what changed in existing elements can cause you to overlook entirely new components added to the design.
3. **Ignoring removed elements** — If the design no longer shows something the code has, flag it for removal rather than leaving dead UI.
4. **Spacing shortcuts** — Never eyeball spacing. Extract exact values from `get_design_context` properties (padding, gap, itemSpacing).
5. **Font weight/width confusion** — Figma "Expanded Semibold" is `.semibold` weight + `.width(.expanded)`, not just `.semibold`. Check both weight and width.

