---
name: pencil-ios-design
description: >
  iOS-specific Pencil MCP design workflow. Creates iOS screens on canvas following
  Apple HIG with proper SF Pro typography, semantic colors, and 8pt spacing grid.
  Use when designing iOS UI in .pen files. Requires Pencil MCP server.
---

# Pencil iOS Design

How to design iOS screens using Pencil MCP tools. Every step follows Apple HIG.

Source tools: [partme-ai/full-stack-skills](https://github.com/partme-ai/full-stack-skills/tree/main/skills/pencil-skills)

## Prerequisites

Pencil MCP server must be configured. Check with `get_editor_state`.

## Workflow

### 1. Open or Create Document

```
Call: open_document("new")     ← new blank canvas
Call: open_document("/path")   ← existing .pen file
```

Then always call `get_editor_state` to confirm active document and schema.

### 2. Initialize iOS Design Tokens

Call `set_variables` with iOS system values. See `ios-design-tokens` skill for full specs.

Key variables to set:
- **Font**: SF Pro, sizes 11-34pt per iOS type scale
- **Colors**: iOS semantic colors (label, background, tints) for light AND dark
- **Spacing**: 4, 8, 12, 16, 20, 24, 32, 48 on the 8pt grid
- **Radii**: 8, 12, 16, 20 with continuous (squircle) corners

### 3. Get iOS Design Guidelines

```
Call: get_guidelines(topic="mobile-app")
```

This returns Apple HIG and mobile-specific rules. Read before designing.

### 4. Get Style Guide (Optional)

If the user wants a specific aesthetic:
```
Call: get_style_guide_tags    ← browse available tags
Call: get_style_guide(tags=["Dark", "Minimal", "Premium"])
```

### 5. Find Canvas Space

Before placing a new screen:
```
Call: find_empty_space_on_canvas(width=393, height=852)
```

Standard iPhone 15 Pro frame: **393 x 852pt** (logical, safe area content).
Full frame with status bar + home indicator: **393 x 852pt**.

Common iOS frame sizes:
| Device | Width | Height |
|--------|-------|--------|
| iPhone 15 Pro | 393pt | 852pt |
| iPhone 15 Pro Max | 430pt | 932pt |
| iPhone SE | 375pt | 667pt |
| iPad (10th gen) | 820pt | 1180pt |

### 6. Design the Screen

Use `batch_design` with insert operations. Max 25 operations per call.

**iOS Layout Rules (enforce these):**

- Content starts below safe area (59pt from top for Dynamic Island)
- 16-20pt horizontal margins
- All touch targets ≥ 44x44pt
- 8pt grid for all spacing
- Use iOS semantic colors (not hardcoded hex)
- Navigation at top, tab bar at bottom (49pt)
- Continuous corner radius (squircle), not circular
- One focal point per screen

**Typography Rules:**
- Title: `.title` or `.largeTitle` — never custom sizes
- Body text: 17pt Regular — this is the iOS standard
- Secondary: `.subheadline` (15pt) or `.footnote` (13pt)
- Max 2 font weights per screen
- Never force specific sizes — use Dynamic Type text styles

**Color Rules:**
- Use semantic colors: `Color(.label)`, `Color(.systemBackground)`
- One accent/tint color per app (default: systemBlue #007AFF)
- Dark mode: don't invert — use semantic tokens that adapt
- `#000000` for dark bg, not `#1C1C1E` (that's secondary)

### 7. Verify with Screenshot

After designing:
```
Call: get_screenshot(nodeId="frame-id")
```

Check the screenshot against these criteria:
- [ ] Proper spacing (8pt grid)
- [ ] Touch targets ≥ 44pt
- [ ] Typography hierarchy clear (squint test)
- [ ] One focal point dominates
- [ ] Would Apple ship this?

### 8. Check Layout Issues

```
Call: snapshot_layout(nodeId="frame-id", problemsOnly=true)
```

Fix any: clipped content, overlapping elements, elements outside frame bounds.

### 9. Audit Design Properties

```
Call: search_all_unique_properties(nodeId="frame-id", properties=["fillColor", "fontFamily", "fontSize"])
```

Verify:
- Only SF Pro font family used
- Only iOS type scale sizes (11, 12, 13, 15, 16, 17, 20, 22, 28, 34)
- Only semantic colors (no random hex values)
- Consistent corner radii

### 10. Export to SwiftUI

Pencil can export nodes to SwiftUI code. Use this as the starting point,
then refine in Xcode with XcodeBuildMCP.

## Common iOS Screen Patterns

### Login Screen
```
Frame: 393 x 852
├── Status bar area (59pt, clear)
├── Spacer (flexible, pushes content to center-upper)
├── App logo/icon (80x80pt, centered)
│   spacing-24
├── Title "Welcome" (.title2, 22pt, centered)
│   spacing-8
├── Subtitle (.subheadline, 15pt, secondaryLabel, centered)
│   spacing-32
├── Email field (height 50pt, radius-md 12pt, horizontal margin 20pt)
│   spacing-12
├── Password field (same)
│   spacing-24
├── Sign In button (height 50pt, radius-md, systemBlue, white label, full width - 40pt)
│   spacing-16
├── "Forgot password?" (.subheadline, systemBlue, centered)
├── Spacer (flexible)
├── "Don't have an account? Sign Up" (.footnote, bottom, centered)
│   spacing-34 (home indicator safe area)
```

### Settings / List Screen
```
Frame: 393 x 852
├── Navigation bar (96pt, large title "Settings")
├── Grouped list (systemGroupedBackground)
│   ├── Section
│   │   ├── Row (44pt height, 20pt leading, disclosure indicator)
│   │   ├── Separator (leading: 20pt, not full-width)
│   │   └── Row
│   ├── Section header (.footnote, uppercase, secondaryLabel, 16pt leading)
│   │   ├── Row with toggle (44pt, switch aligned trailing -20pt)
│   │   └── Row
│   └── ...
├── Tab bar (49pt, 5 items, systemBlue selected)
│   spacing-34 (home indicator)
```

### Detail Screen
```
Frame: 393 x 852
├── Navigation bar (44pt, back button, title centered)
├── Hero image (full width, 250pt height)
│   spacing-16
├── Content (20pt horizontal margins)
│   ├── Title (.title2, 22pt)
│   │   spacing-8
│   ├── Metadata (.subheadline, secondaryLabel)
│   │   spacing-16
│   ├── Body text (.body, 17pt, multiline)
│   │   spacing-24
│   └── Action button (50pt, full width - 40pt, systemBlue)
├── Spacer
│   spacing-34 (home indicator)
```

## Anti-Patterns (Never Do These)

- Custom font sizes not in the iOS type scale
- Touch targets under 44pt
- Hardcoded colors instead of semantic tokens
- Circular corners instead of continuous (squircle)
- Full-bleed separators (iOS uses inset separators, leading edge)
- Tab bar with more than 5 items
- Navigation title on the left (it's centered or large-title left-aligned)
- Forgetting safe areas (content under Dynamic Island or home indicator)
