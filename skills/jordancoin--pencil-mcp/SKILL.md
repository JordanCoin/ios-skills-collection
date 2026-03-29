---
name: pencil-mcp
description: Pencil.dev MCP integration for AI-native UI design. Design on canvas, export real SwiftUI/React code. Use when building UI with visual design tools that output production code.
---

# Pencil MCP

Pencil.dev is an AI-native design tool that outputs actual code — not mockups you have to translate. The MCP integration lets AI agents design directly on canvas.

## Installation

Add to your MCP config:
```json
{
  "mcpServers": {
    "pencil": {
      "command": "npx",
      "args": ["-y", "@anthropics/pencil-mcp"]
    }
  }
}
```

## Core Capabilities

### Project Management
- `get_editor_state` — Get current design context (selection, canvas position)
- `open_document` — Open or create a design document
- `snapshot_layout` — Get page layout structure (DOM-like tree)

### Design Execution
- `batch_design` — Batch insert, update, move, or delete nodes (the "hands")
- `batch_get` — Batch search and read node information (the "eyes")
- `find_empty_space_on_canvas` — Find empty space for new artboards
- `search_all_unique_properties` — Global property search (audit)
- `replace_all_matching_properties` — Global batch replace (refactor)

### Visual Guidelines
- `get_guidelines` — Read design system specs (Apple HIG, Material, custom)
- `get_style_guide_tags` — Explore style directions (Modern, Dark Mode, SaaS)
- `get_style_guide` — Get specific style metadata (palettes, typography)
- `get_variables` — Read Design Tokens from current document
- `set_variables` — Set or update Design Tokens

### Visual Verification
- `get_screenshot` — Capture node/artboard screenshot for verification

## The Design Loop

1. **Understand**: Get user intent, call `get_editor_state` for context
2. **Explore**: Check components via `batch_get`, consult `get_guidelines`
3. **Propose**: Outline steps before complex operations
4. **Execute**: Call `batch_design` for design changes
5. **Verify**: Call `get_screenshot` to capture and self-evaluate
6. **Feedback**: Show results, ask for adjustments

## Key Principles

- **Read Before Write**: Always read node state before modifying
- **Atomic Operations**: Use batch operations for efficiency
- **Visual Verification**: Screenshot after changes to validate
- **Design System First**: Check guidelines before custom styling

## SwiftUI Export

Pencil outputs actual SwiftUI code:
```swift
// Exported from Pencil.dev
struct LoginView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.bold)
            // ... actual SwiftUI, not pseudo-code
        }
    }
}
```

## Integration with XcodeBuildMCP

After Pencil exports SwiftUI:
1. Save to .swift file
2. `xcodebuildmcp simulator build --scheme MyApp`
3. `xcodebuildmcp ui-automation screenshot`
4. Compare screenshot to Pencil design
5. Iterate if needed

## Resources

- Pencil.dev: https://pencil.dev
- Pencil Skills: https://github.com/partme-ai/pencil-skills
- Agent Skills Spec: https://agentskills.io/specification
