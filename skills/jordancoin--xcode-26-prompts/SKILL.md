---
name: xcode-26-prompts
description: Xcode 26 internal system prompts for AI agents. Reference for understanding how Apple's agents work in Xcode, including code style, tool usage, and validation patterns.
---

# Xcode 26 System Prompts

This skill contains extracted system prompts from Xcode 26's AI agent integration. Use these as reference for understanding Apple's official patterns for AI-assisted iOS development.

Source: [artemnovichkov/xcode-26-system-prompts](https://github.com/artemnovichkov/xcode-26-system-prompts)

## Key Insights from Xcode 26 Prompts

### Combine is Officially Deprecated
Apple's internal agent prompt states:
> "Avoid using the Combine framework and instead prefer to use Swift's async and await versions of APIs instead."

### Must-Search Topics
Xcode instructs agents to ALWAYS search documentation for:
- **Liquid Glass** — New design system
- **FoundationModels** — On-device ML framework with structured generation macros
- **SwiftUI** — Constantly evolving, don't assume knowledge is current

### Code Style Guidelines (Official)
- **Naming**: PascalCase for types, camelCase for properties/methods
- **Properties**: Use `@State private var` for SwiftUI state, `let` for constants
- **Structure**: Conform views to `View` protocol, define UI in `body` property
- **Formatting**: 4-space indentation, clear method separation
- **Imports**: Simple imports at top of file (SwiftUI, Foundation)
- **Types**: Leverage Swift's strong type system, avoid force unwrapping
- **Architecture**: Follow SwiftUI patterns with clear separation of concerns
- **Comments**: Add descriptive comments for complex logic
- **Testing**: Use Testing framework for unit tests, XCUIAutomation for UI tests

### Tool Usage Pattern
Xcode agents should prefer `xcode-tools` MCP server over shell commands:
- Use `DocumentationSearch` to search Apple docs
- Use `BuildProject` to build (but sparingly - builds take time)
- Use `XcodeRefreshCodeIssuesInFile` for fast "live" diagnostics
- Use `ExecuteSnippet` to try code in a REPL-like environment

### Key Rule
> "Be sure to limit your changes to the things that I ask for. For example, if I ask you to add a button, don't make unrelated changes to other parts of the project."

## Available Prompt Templates

The full repo contains these templates:
- `AgentSystemPromptAddition.idechatprompttemplate` — Main agent context
- `BasicSystemPrompt.idechatprompttemplate` — Base system prompt
- `ReasoningSystemPrompt.idechatprompttemplate` — Extended thinking mode
- `PlannerExecutorStyle*.idechatprompttemplate` — Planning patterns
- `GeneratePreview.idechatprompttemplate` — SwiftUI preview generation
- `GeneratePlayground.idechatprompttemplate` — Playground creation
- And many more...

## Usage

Reference these patterns when:
1. Building AI agents for iOS development
2. Understanding Apple's official coding standards
3. Configuring MCP tools for Xcode integration
4. Writing prompts for Swift/SwiftUI code generation

For full prompt files, clone: `gh repo clone artemnovichkov/xcode-26-system-prompts`
