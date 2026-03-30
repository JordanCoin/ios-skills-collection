# iOS Skills Collection

[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20iPadOS%20%7C%20macOS-000000.svg?logo=apple)](https://developer.apple.com)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-d97757.svg?logo=anthropic)](https://claude.ai/code)
[![OpenAI Codex](https://img.shields.io/badge/OpenAI%20Codex-compatible-10A37F.svg)](https://developers.openai.com/codex)
[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-standard-green.svg)](https://agentskills.io)
[![Skills](https://img.shields.io/badge/Skills-200%2B-blue.svg)](skills/)
[![Authors](https://img.shields.io/badge/Authors-28-purple.svg)](sources.json)

The largest collection of iOS/Swift/Xcode AI agent skills. 200+ SKILL.md files from 28 authors
including [Paul Hudson (twostraws)](https://github.com/twostraws), [Antoine van der Lee (AvdLee)](https://github.com/AvdLee),
[Thomas Ricouard (Dimillian)](https://github.com/Dimillian), and [dpearson2699](https://github.com/dpearson2699).

Phase-aware routing auto-injects the right skills based on what you're editing.
Works with **Claude Code** (plugin + hooks), **OpenAI Codex CLI**, and **Codex Mac App**.

Covers SwiftUI, Swift Concurrency, SwiftData, UIKit, 76 Apple frameworks (HealthKit, MapKit,
ARKit, CoreML, StoreKit, etc.), App Store Connect, ASO, Xcode build optimization, accessibility,
testing, security, and the full idea-to-deploy lifecycle.

Skills sourced from [twostraws/Swift-Agent-Skills](https://github.com/twostraws/Swift-Agent-Skills) community directory and the broader iOS agent skills ecosystem.

> **Before you install:** Agent skills are injected directly into your AI assistant's
> context window and influence how it writes code. Review any skill before trusting it.
> Every skill in this collection links to its upstream source repo in the
> [Sources](#sources) section below — verify the authors and read the SKILL.md files
> you plan to use. Being included here is not an endorsement. All skills are open source
> (MIT licensed) and can be audited. Use at your own discretion.

## Install

**Everything (recommended):**
```bash
git clone https://github.com/JordanCoin/ios-skills-collection ~/.agents/ios-skills && ~/.agents/ios-skills/install.sh --all
```

**Claude Code only:**
```bash
git clone https://github.com/JordanCoin/ios-skills-collection ~/.claude/ios-skills && claude plugins add ~/.claude/ios-skills
```

**Codex only (CLI + Mac App):**
```bash
git clone https://github.com/JordanCoin/ios-skills-collection ~/.agents/ios-skills && ~/.agents/ios-skills/install.sh --codex
```

**Per-project:**
```bash
git clone https://github.com/JordanCoin/ios-skills-collection .ios-skills && claude --plugin-dir .ios-skills
```

| Agent | What install does |
|-------|-------------------|
| Claude Code | Registers as plugin with hooks (auto-inject skills on file edit) |
| Codex CLI | Symlinks skills to `~/.agents/skills/` (auto-activate on description match) |
| Codex Mac App | Plugin bundle at `~/plugins/ios-skills` + marketplace registration |

## How It Works

Skills auto-inject based on what you're doing:

| You do this | Skills fire |
|---|---|
| Edit `*View.swift` | swiftui-pro + ios-accessibility |
| Edit `*Tests.swift` | swift-testing-pro + swift-testing-expert |
| Edit `*Model.swift` | swiftdata-pro + core-data |
| Write `import HealthKit` | healthkit |
| Write `import CoreBluetooth` | core-bluetooth |
| Run `xcodebuild` | xcodebuild-cli + xcode-build-orchestrator |
| Run `swift test` | swift-testing-pro |
| Run `asc builds list` | asc-cli + asc-workflow |
| Edit `Info.plist` | app-store-preflight |
| Edit `*.strings` | ios-localization |

A router skill loads at session start with:
- **Knowledge corrections** — 25+ "your training data is wrong" overrides for deprecated APIs
- **Decision matrix** — "if you need X, use Y" lookup table
- **Phase map** — which skills to load for each development stage

## Phases

```
IDEATION → DESIGN → DEVELOP → TEST → DEPLOY → ITERATE
```

200+ skills organized across 6 phases. The router guides the agent to the right
skills based on what phase you're in. See `skills/_router/SKILL.md` for the full map.

## Update

Skills are synced from upstream repos. The plugin warns at session start if they're stale.

```bash
./sync.sh           # pull latest from all upstream repos
./sync.sh --check   # just check what's changed, don't update
./sync.sh --status  # show last sync time and upstream SHAs
```

## Sources

All skills are vendored with attribution. Each directory is prefixed with the source author.
[Paul Hudson](https://github.com/twostraws) (Hacking with Swift) skills are primary for all overlapping domains.

### Core Skills (primary — used first for overlapping domains)

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **Paul Hudson** | [twostraws/SwiftUI-Agent-Skill](https://github.com/twostraws/SwiftUI-Agent-Skill) | 1 | SwiftUI best practices |
| **Paul Hudson** | [twostraws/Swift-Concurrency-Agent-Skill](https://github.com/twostraws/Swift-Concurrency-Agent-Skill) | 1 | async/await, actors, Sendable |
| **Paul Hudson** | [twostraws/SwiftData-Agent-Skill](https://github.com/twostraws/SwiftData-Agent-Skill) | 1 | SwiftData persistence |
| **Paul Hudson** | [twostraws/Swift-Testing-Agent-Skill](https://github.com/twostraws/Swift-Testing-Agent-Skill) | 1 | Swift Testing framework |

### Framework Coverage

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **dpearson2699** | [dpearson2699/swift-ios-skills](https://github.com/dpearson2699/swift-ios-skills) | 76 | Every Apple framework (HealthKit, MapKit, ARKit, CoreML, StoreKit, etc.) |

### SwiftUI & Architecture

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **Thomas Ricouard** | [Dimillian/Skills](https://github.com/Dimillian/Skills) | 16 | SwiftUI patterns, performance audit, Liquid Glass, concurrency, code review swarm, debugger agent |
| **Antoine van der Lee** | [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) | 2 | SwiftUI expert + API updates |
| **Antoine van der Lee** | [AvdLee/Swift-Testing-Agent-Skill](https://github.com/AvdLee/Swift-Testing-Agent-Skill) | 1 | Swift Testing expert |
| **Antoine van der Lee** | [AvdLee/Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) | 1 | Concurrency expert |
| **Antoine van der Lee** | [AvdLee/Core-Data-Agent-Skill](https://github.com/AvdLee/Core-Data-Agent-Skill) | 1 | Core Data expert |
| **Antoine van der Lee** | [AvdLee/Xcode-Build-Optimization-Agent-Skill](https://github.com/AvdLee/Xcode-Build-Optimization-Agent-Skill) | 6 | Build benchmarking + optimization |
| **Arjit Jaiswal** | [arjitj2/swiftui-design-principles](https://github.com/arjitj2/swiftui-design-principles) | 1 | SwiftUI design principles |
| **Lasha Efremidze** | [efremidze/swift-architecture-skill](https://github.com/efremidze/swift-architecture-skill) | 1 | MVVM, TCA, VIPER, Clean Architecture |

### Testing & Quality

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **Eduardo Bocato** | [bocato/swift-testing-agent-skill](https://github.com/bocato/swift-testing-agent-skill) | 1 | Swift Testing patterns + snapshot testing |
| **Kudrin Dmitry** | [vanab/swiftdata-agent-skill](https://github.com/vanab/swiftdata-agent-skill) | 1 | SwiftData expert |

### Accessibility

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **Daniel Devesa** | [dadederk/iOS-Accessibility-Agent-Skill](https://github.com/dadederk/iOS-Accessibility-Agent-Skill) | 1 | iOS accessibility best practices |
| **Pasquale Vittoriosi** | [PasqualeVittoriosi/swift-accessibility-skill](https://github.com/PasqualeVittoriosi/swift-accessibility-skill) | 1 | WCAG 2.2 + App Store Nutrition Labels |
| **Roberto Gomez** | [rgmez/apple-accessibility-skills](https://github.com/rgmez/apple-accessibility-skills) | 3 | AppKit, SwiftUI, UIKit accessibility auditors |

### Security & API Design

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **Ivan Magda** | [ivan-magda/swift-security-skill](https://github.com/ivan-magda/swift-security-skill) | 1 | Keychain, CryptoKit, Secure Enclave, biometrics |
| **Erik Sebastian** | [Erikote04/Swift-API-Design-Guidelines](https://github.com/Erikote04/Swift-API-Design-Guidelines-Agent-Skill) | 1 | Swift API naming conventions |

### App Store & ASO

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **truongduy2611** | [truongduy2611/app-store-preflight-skills](https://github.com/truongduy2611/app-store-preflight-skills) | 1 | App Store rejection scanner |
| **Rudrank Riyam** | [rudrankriyam/app-store-connect-cli-skills](https://github.com/rudrankriyam/app-store-connect-cli-skills) | 22 | App Store Connect CLI automation |
| **Eronred** | [Eronred/aso-skills](https://github.com/Eronred/aso-skills) | 30 | App Store Optimization (keywords, metadata, competitors) |
| **Tim Broddin** | [timbroddin/app-store-aso-skill](https://github.com/timbroddin/app-store-aso-skill) | 1 | ASO learnings |

### Tools & Workflows

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **harryworld** | [harryworld/Xcode26-Agent-Skills](https://github.com/harryworld/Xcode26-Agent-Skills) | 1 | Xcode 26, Liquid Glass, Foundation Models |
| **conorluddy** | [conorluddy/ios-simulator-skill](https://github.com/conorluddy/ios-simulator-skill) | 1 | iOS Simulator automation with scripts |
| **daetojemax** | [daetojemax/figma-to-swiftui-skill](https://github.com/daetojemax/figma-to-swiftui-skill) | 1 | Figma design to SwiftUI code |
| **arimunandar** | [arimunandar/claude-code-ios-plugin](https://github.com/arimunandar/claude-code-ios-plugin) | 11 | UIKit, VIP architecture, security, code review |
| **andrewgleave** | [andrewgleave/skills](https://github.com/andrewgleave/skills) | 3 | Code cleanse, critical reasoning, writing for interfaces |

### Original Skills

| Author | Repo | Skills | Description |
|--------|------|--------|-------------|
| **JordanCoin** | [JordanCoin/swift-agent-skills](https://github.com/JordanCoin/swift-agent-skills) | 12 | Swift/SwiftUI/Xcode tooling, Core Data, style guide |
| **JordanCoin** | [JordanCoin/ios-design-stack](https://github.com/JordanCoin/ios-design-stack) | 3 | Design philosophy, Pencil MCP, Ralph Loop |

Source mapping in `sources.json`. Most upstream repos are MIT licensed.
**Exception:** [dpearson2699/swift-ios-skills](https://github.com/dpearson2699/swift-ios-skills) (76 skills) is licensed under
[PolyForm Perimeter 1.0.0](https://polyformproject.org/licenses/perimeter/1.0.0/) —
see their [LICENSE](https://github.com/dpearson2699/swift-ios-skills/blob/main/LICENSE) for terms.

## License

MIT
