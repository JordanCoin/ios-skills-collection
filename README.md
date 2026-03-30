# iOS Skills Collection

169 iOS/Swift/Xcode agent skills aggregated from 11 authors with phase-aware routing.
Works with Claude Code (plugin + hooks) and Codex CLI (raw skills).

## Install

```bash
git clone https://github.com/JordanCoin/ios-skills-collection
cd ios-skills-collection

# Claude Code
claude plugins add .

# Codex CLI
./install.sh --codex

# Both
./install.sh --all
```

## How It Works

Skills auto-inject based on what you're doing:

| You do this | Skills fire |
|---|---|
| Edit `*View.swift` | swiftui-pro + ios-accessibility |
| Edit `*Tests.swift` | swift-testing-expert |
| Edit `*Model.swift` | swiftdata-pro + core-data |
| Write `import HealthKit` | healthkit |
| Run `xcodebuild` | xcodebuild-cli + xcode-build-orchestrator |
| Run `asc builds list` | asc-cli + asc-workflow |
| Edit `Info.plist` | app-store-preflight |

A router skill loads at session start with a knowledge corrections table,
decision matrix, and phase map so the agent always knows what's available.

## Phases

```
IDEATION → DESIGN → DEVELOP → TEST → DEPLOY → ITERATE
```

169 skills organized across 6 phases. The router guides the agent to the right
skills based on what phase you're in. See `skills/_router/SKILL.md` for the full map.

## Update

```bash
./sync.sh           # pull latest from all upstream repos
./sync.sh --check   # just check what's changed, don't update
./sync.sh --status  # show last sync time and upstream SHAs
```

## Sources

All skills are vendored from their upstream repos with attribution.
Each skill directory is prefixed with the source author (`twostraws--`, `avdlee--`, etc.).

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **Paul Hudson** | [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill) | 1 | SwiftUI best practices |
| **Paul Hudson** | [twostraws/Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill) | 1 | async/await, actors, Sendable |
| **Paul Hudson** | [twostraws/SwiftData-Agent-Skill](https://github.com/twostraws/SwiftData-Agent-Skill) | 1 | SwiftData persistence |
| **Antoine van der Lee** | [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) | 2 | SwiftUI expert + API updates |
| **Antoine van der Lee** | [AvdLee/Swift-Testing-Agent-Skill](https://github.com/AvdLee/Swift-Testing-Agent-Skill) | 1 | Swift Testing framework |
| **Antoine van der Lee** | [AvdLee/Xcode-Build-Optimization-Agent-Skill](https://github.com/AvdLee/Xcode-Build-Optimization-Agent-Skill) | 6 | Build benchmarking + optimization |
| **dpearson2699** | [dpearson2699/swift-ios-skills](https://github.com/dpearson2699/swift-ios-skills) | 76 | Every Apple framework |
| **truongduy2611** | [truongduy2611/app-store-preflight-skills](https://github.com/truongduy2611/app-store-preflight-skills) | 1 | App Store rejection scanner |
| **dadederk** | [dadederk/iOS-Accessibility-Agent-Skill](https://github.com/dadederk/iOS-Accessibility-Agent-Skill) | 1 | iOS accessibility best practices |
| **Pasquale Vittoriosi** | [PasqualeVittoriosi/swift-accessibility-skill](https://github.com/PasqualeVittoriosi/swift-accessibility-skill) | 1 | WCAG 2.2 + Nutrition Labels |
| **harryworld** | [harryworld/Xcode26-Agent-Skills](https://github.com/harryworld/Xcode26-Agent-Skills) | 1 | Xcode 26, Liquid Glass |
| **Rudrank Riyam** | [rudrankriyam/app-store-connect-cli-skills](https://github.com/rudrankriyam/app-store-connect-cli-skills) | 22 | App Store Connect CLI |
| **Eronred** | [Eronred/aso-skills](https://github.com/Eronred/aso-skills) | 30 | App Store Optimization |
| **arimunandar** | [arimunandar/claude-code-ios-plugin](https://github.com/arimunandar/claude-code-ios-plugin) | 11 | UIKit, VIP architecture, security |
| **JordanCoin** | [JordanCoin/swift-agent-skills](https://github.com/JordanCoin/swift-agent-skills) | 12 | Swift/SwiftUI/Xcode tooling |
| **JordanCoin** | [JordanCoin/ios-design-stack](https://github.com/JordanCoin/ios-design-stack) | 3 | Design philosophy, Pencil MCP, Ralph Loop |

All upstream repos are MIT licensed.

## License

MIT
