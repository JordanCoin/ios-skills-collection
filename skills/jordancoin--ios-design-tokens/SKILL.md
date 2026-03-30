---
name: ios-design-tokens
description: >
  iOS design system tokens for Pencil MCP: SF Pro typography scale, iOS semantic colors
  (light + dark mode hex values), spacing grid, touch targets, corner radii, and component
  heights. Use when initializing a .pen file for iOS design or setting up design variables.
---

# iOS Design Tokens

Design tokens for iOS apps following Apple HIG. Use these with Pencil MCP's
`set_variables` tool to initialize a .pen file for iOS design.

## Typography — SF Pro

SF Pro Text at 19pt and below. SF Pro Display at 20pt and above.

| Style | Weight | Size | Leading | SwiftUI |
|-------|--------|------|---------|---------|
| Large Title | Regular | 34pt | 41pt | `.largeTitle` |
| Title 1 | Light | 28pt | 34pt | `.title` |
| Title 2 | Regular | 22pt | 28pt | `.title2` |
| Title 3 | Regular | 20pt | 24pt | `.title3` |
| Headline | Semi-Bold | 17pt | 22pt | `.headline` |
| Body | Regular | 17pt | 22pt | `.body` |
| Callout | Regular | 16pt | 21pt | `.callout` |
| Subhead | Regular | 15pt | 20pt | `.subheadline` |
| Footnote | Regular | 13pt | 18pt | `.footnote` |
| Caption 1 | Regular | 12pt | 16pt | `.caption` |
| Caption 2 | Regular | 11pt | 13pt | `.caption2` |

## Colors — iOS Semantic (Light / Dark)

### Labels
| Token | Light | Dark | SwiftUI |
|-------|-------|------|---------|
| label | #000000 | #FFFFFF | `Color(.label)` |
| secondaryLabel | #3C3C43/60% | #EBEBF5/60% | `Color(.secondaryLabel)` |
| tertiaryLabel | #3C3C43/30% | #EBEBF5/30% | `Color(.tertiaryLabel)` |
| placeholderText | #3C3C43/30% | #EBEBF5/30% | `Color(.placeholderText)` |

### Backgrounds (Grouped — most common for iOS)
| Token | Light | Dark | SwiftUI |
|-------|-------|------|---------|
| groupedBackground | #F2F2F7 | #000000 | `Color(.systemGroupedBackground)` |
| secondaryGroupedBg | #FFFFFF | #1C1C1E | `Color(.secondarySystemGroupedBackground)` |
| tertiaryGroupedBg | #F2F2F7 | #2C2C2E | `Color(.tertiarySystemGroupedBackground)` |

### Backgrounds (Flat)
| Token | Light | Dark | SwiftUI |
|-------|-------|------|---------|
| systemBackground | #FFFFFF | #000000 | `Color(.systemBackground)` |
| secondaryBg | #F2F2F7 | #1C1C1E | `Color(.secondarySystemBackground)` |

### System Tints
| Token | Light | Dark | SwiftUI |
|-------|-------|------|---------|
| blue | #007AFF | #0A84FF | `.blue` |
| green | #34C759 | #30D158 | `.green` |
| red | #FF3B30 | #FF453A | `.red` |
| orange | #FF9500 | #FF9F0A | `.orange` |
| yellow | #FFCC00 | #FFD60A | `.yellow` |
| purple | #AF52DE | #BF5AF2 | `.purple` |
| pink | #FF2D55 | #FF375F | `.pink` |
| indigo | #5856D6 | #5E5CE6 | `.indigo` |
| teal | #5AC8FA | #64D2FF | `.teal` |

### Fills and Separators
| Token | Light | Dark |
|-------|-------|------|
| systemFill | #787880/20% | #787880/36% |
| separator | #3C3C43/29% | #545458/60% |
| opaqueSeparator | #C6C6C8 | #38383A |

### Grays
| Token | Light | Dark |
|-------|-------|------|
| systemGray | #8E8E93 | #8E8E93 |
| systemGray2 | #AEAEB2 | #636366 |
| systemGray3 | #C7C7CC | #48484A |
| systemGray4 | #D1D1D6 | #3A3A3C |
| systemGray5 | #E5E5EA | #2C2C2E |
| systemGray6 | #F2F2F7 | #1C1C1E |

## Spacing — 8pt Grid

| Token | Value | Use |
|-------|-------|-----|
| `spacing-2` | 2pt | Hairline, icon internal |
| `spacing-4` | 4pt | Micro, tight elements |
| `spacing-8` | 8pt | Small, compact spacing |
| `spacing-12` | 12pt | Between related items |
| `spacing-16` | 16pt | Standard padding, compact margins |
| `spacing-20` | 20pt | Default layout margins (iPhone) |
| `spacing-24` | 24pt | Section internal padding |
| `spacing-32` | 32pt | Section spacing |
| `spacing-48` | 48pt | Major section breaks |

## Touch Targets

- **Minimum**: 44 x 44pt (Apple HIG requirement — never smaller)
- **Recommended**: 48 x 48pt
- Tab bar icon touch area: 44pt minimum

## Corner Radii

| Token | Value | Use |
|-------|-------|-----|
| `radius-sm` | 8pt | Small cards, chips |
| `radius-md` | 12pt | Cards, input fields |
| `radius-lg` | 16pt | Large cards, modals |
| `radius-xl` | 20pt | Widgets, full-width cards |
| Use `.continuous` | — | Always use continuous (squircle) corners, not circular |

## Component Heights

| Component | Height |
|-----------|--------|
| Navigation Bar | 44pt (standard), 96pt (large title) |
| Tab Bar | 49pt |
| Search Bar | 36pt field |
| Primary Button | 50pt |
| Toolbar | 44pt |
| Status Bar | 54pt (Dynamic Island), 44pt (notch) |

## Safe Areas

| Edge | Value |
|------|-------|
| Top | 59pt (Dynamic Island) / 44pt (notch) |
| Bottom | 34pt (home indicator) |

## Pencil MCP: Initialize iOS Design File

When creating a new .pen file for iOS design, run `set_variables` with these tokens:
```
Font Family: SF Pro
Font sizes: 11, 12, 13, 15, 16, 17, 20, 22, 28, 34
Spacing: 4, 8, 12, 16, 20, 24, 32, 48
Primary: #007AFF (light) / #0A84FF (dark)
Background: #FFFFFF (light) / #000000 (dark)
Surface: #F2F2F7 (light) / #1C1C1E (dark)
Label: #000000 (light) / #FFFFFF (dark)
Secondary Label: #3C3C43/60% (light) / #EBEBF5/60% (dark)
```
