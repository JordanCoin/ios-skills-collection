---
name: apple-docs-mcp
description: MCP server for searching Apple Developer Documentation. Access iOS/macOS/SwiftUI/UIKit docs, WWDC videos, and code examples directly in AI assistants.
---

# Apple Docs MCP

An MCP (Model Context Protocol) server that provides AI agents with direct access to Apple Developer Documentation.

Source: [kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)

## Installation

### Claude Desktop / Claude Code
```bash
claude mcp add apple-docs -- npx -y @kimsungwhee/apple-docs-mcp@latest
```

### MCP Config (Claude Desktop, Cursor, etc.)
```json
{
  "mcpServers": {
    "apple-docs": {
      "command": "npx",
      "args": ["-y", "@kimsungwhee/apple-docs-mcp"]
    }
  }
}
```

### Xcode Integration
Xcode 26.3+ has built-in MCP support. Use `DocumentationSearch` from xcode-tools.

## Capabilities

- **Smart Search**: Search across SwiftUI, UIKit, Foundation, CoreData, ARKit, etc.
- **Complete Documentation**: Full access to Apple's JSON API
- **Framework Index**: Browse hierarchical API structures
- **WWDC Videos**: Search sessions 2014-2025 with transcripts
- **Sample Code**: Swift and Objective-C examples
- **Platform Compatibility**: iOS, macOS, watchOS, tvOS, visionOS analysis
- **Beta Tracking**: iOS 26 beta APIs, deprecated methods, new features

## Usage Examples

### Smart Search
```
"Search for SwiftUI animations"
"Find withAnimation API documentation"
"Look up async/await patterns in Swift"
"Show me UITableView delegate methods"
"Search Core Data NSPersistentContainer examples"
```

### Documentation Access
```
"Get detailed information about the SwiftUI framework"
"Show me withAnimation API with related APIs"
"Get platform compatibility for SwiftData"
"Access UIViewController documentation"
```

### Framework Exploration
```
"Show me SwiftUI framework API index"
"List all UIKit classes and methods"
"Browse ARKit framework structure"
"Get WeatherKit API hierarchy"
```

### WWDC Sessions
```
"Search WWDC sessions about SwiftUI"
"Find WWDC 2024 videos on machine learning"
"Get transcripts for async/await sessions"
```

## Why Use This

1. **Faster than web search** — Direct API access to Apple's docs
2. **Always current** — Pulls latest documentation including betas
3. **AI-optimized** — Responses designed for context injection
4. **Offline-capable** — Some features work without network

## Key Topics to Search

For iOS 26+ development, always search for:
- **Liquid Glass** — New design system
- **FoundationModels** — On-device ML framework
- **SwiftUI** — Constantly evolving APIs
- **Swift Testing** — New testing framework
- **Observation** — `@Observable` macro patterns

## Integration Notes

- Works with any MCP-compatible client
- No API key required
- Smart UserAgent rotation for reliability
- Supports multiple concurrent queries
