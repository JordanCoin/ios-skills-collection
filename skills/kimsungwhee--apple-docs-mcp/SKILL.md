---
name: apple-docs-mcp
description: >
  MCP server for Apple Developer Documentation. Search iOS/macOS/SwiftUI/UIKit docs,
  WWDC videos with transcripts, sample code, and framework APIs. Use when you need
  to look up Apple APIs, check platform compatibility, find WWDC sessions, or browse
  framework symbols. Install the MCP server first, then use its tools.
---

# Apple Docs MCP

MCP server for searching Apple Developer Documentation directly from AI agents.
Search APIs, frameworks, WWDC videos, sample code, and platform compatibility.

Source: [kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp) by [@kimsungwhee](https://github.com/kimsungwhee)

## Install

**Claude Code:**
```bash
claude mcp add apple-docs -- npx -y @kimsungwhee/apple-docs-mcp@latest
```

**Codex / .mcp.json:**
```json
{
  "mcpServers": {
    "apple-docs": {
      "command": "npx",
      "args": ["-y", "@kimsungwhee/apple-docs-mcp@latest"]
    }
  }
}
```

## Available Tools

| Tool | Use when |
|------|----------|
| `search_apple_docs` | "How does X work?" — search for any API, class, method |
| `get_apple_doc_content` | Get full docs for a specific API with related APIs + platform compat |
| `search_framework_symbols` | Browse classes/structs/protocols within a framework |
| `get_related_apis` | Find inheritance, conformance, "See Also" relationships |
| `find_similar_apis` | Apple's official recommendations for alternatives |
| `get_platform_compatibility` | Version support, beta status, deprecation for an API |
| `list_technologies` | Browse all Apple technologies by category |
| `get_technology_overviews` | Comprehensive guides for technology areas |
| `get_documentation_updates` | Latest WWDC announcements, release notes |
| `get_sample_code` | Browse Apple sample code projects by framework |
| `search_wwdc_videos` | Search WWDC sessions by keyword, topic, year |
| `get_wwdc_video_details` | Full transcript, code examples, resources for a session |
| `list_wwdc_topics` | 19 topic categories from Swift to Spatial Computing |
| `list_wwdc_years` | Conference years with video counts |

## When to Use

- **Before writing framework code**: search for the API to get correct signatures and patterns
- **Checking deprecations**: use `get_platform_compatibility` before using any API
- **Finding alternatives**: use `find_similar_apis` when an API is deprecated
- **Learning a framework**: use `search_framework_symbols` + `get_technology_overviews`
- **WWDC context**: search videos for the "why" behind API design decisions

## Example Queries

```
search_apple_docs("SwiftUI withAnimation")
get_apple_doc_content("/documentation/swiftui/view/animation(_:value:)")
search_framework_symbols("SwiftUI", "Button")
get_platform_compatibility("/documentation/healthkit")
search_wwdc_videos("Swift concurrency")
get_sample_code("CoreML")
```

## Data

- 1,260+ WWDC sessions with transcripts (2012-2025), bundled offline
- Full Apple Developer Documentation JSON API access
- Smart caching (30min docs, 10min search, 1hr frameworks)
