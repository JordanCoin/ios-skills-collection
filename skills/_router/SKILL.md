---
name: ios-skills-router
description: >
  Always use when working on any iOS, macOS, Swift, SwiftUI, Xcode, or Apple platform project.
  Routes to the correct specialized skills based on development phase and task context.
  This collection contains 169 skills from 11 authors covering the full iOS lifecycle.
---

# iOS Skills Router

You have access to **169 specialized skills** for iOS/Swift/Xcode development.
Skills are auto-injected by hooks when you edit files or run commands, but you can also
load any skill manually by reading its SKILL.md.

## How Routing Works

1. **Auto-injection**: When you edit `*View.swift`, SwiftUI skills load. When you run `xcodebuild`, build skills load. This happens automatically — you don't need to do anything.
2. **Phase guidance**: This router tells you what skills exist for each development phase. Load them when the context calls for it.
3. **Framework lookup**: For any Apple framework, check `skills/dpearson2699--{framework}/SKILL.md`.

## Phases

### 1. Ideation — "What should we build?"
| Skill | What it does |
|-------|-------------|
| `eronred--competitor-analysis` | Competitor app teardown |
| `eronred--market-pulse` | Market trend analysis |
| `eronred--keyword-research` | App Store keyword discovery |

### 2. Design — "How should it look and feel?"
| Skill | What it does |
|-------|-------------|
| `jordancoin--design-philosophy` | Taste-building, Dieter Rams principles |
| `jordancoin--pencil-mcp` | Canvas design → SwiftUI code via Pencil MCP |
| `dadederk--ios-accessibility` | VoiceOver, Dynamic Type, assistive tech |
| `pasqualevittoriosi--swift-accessibility` | WCAG 2.2, App Store Nutrition Labels |

### 3. Develop — "Build it"
**Core (auto-injected on .swift files):**
| Skill | What it does |
|-------|-------------|
| `twostraws--swiftui-pro` | SwiftUI best practices (primary) |
| `twostraws--swift-concurrency-pro` | async/await, actors, Sendable |
| `twostraws--swiftdata-pro` | SwiftData persistence |
| `jordancoin--swift-style-guide` | Swift coding conventions |
| `jordancoin--core-data` | Core Data stack, migrations, threading |

**Architecture:**
| Skill | What it does |
|-------|-------------|
| `arimunandar--vip-architecture` | VIP+W Clean Architecture |
| `arimunandar--uikit-layouting` | UIKit horizontal-first layout |
| `arimunandar--legacy-migration` | UIKit → SwiftUI migration |

**76 Framework Skills** — load when you see the import:
```
import HealthKit    → dpearson2699--healthkit
import MapKit       → dpearson2699--mapkit
import StoreKit     → dpearson2699--storekit
import CloudKit     → dpearson2699--cloudkit
import CoreML       → dpearson2699--coreml
import RealityKit   → dpearson2699--realitykit
import WidgetKit    → dpearson2699--widgetkit
import GameKit      → dpearson2699--gamekit
import PencilKit    → dpearson2699--pencilkit
import AVKit        → dpearson2699--avkit
(... pattern: dpearson2699--{lowercase-framework-name})
```

Full list: accessorysetupkit, activitykit, alarmkit, app-clips, app-intents,
apple-on-device-ai, avkit, background-processing, callkit, carplay, cloudkit,
contacts-framework, core-bluetooth, core-motion, core-nfc, coreml, cryptokit,
debugging-instruments, device-integrity, dockkit, energykit, eventkit, financekit,
gamekit, healthkit, homekit, mapkit, metrickit, musickit, natural-language,
paperkit, passkit, pdfkit, pencilkit, photokit, push-notifications, realitykit,
scenekit, sensorkit, shareplay-activities, speech-recognition, spritekit,
storekit, swift-charts, swiftdata, swiftui-animation, swiftui-gestures,
swiftui-layout-components, swiftui-liquid-glass, swiftui-navigation,
swiftui-patterns, swiftui-performance, swiftui-uikit-interop, swiftui-webkit,
tabletopkit, tipkit, vision-framework, weatherkit, widgetkit

### 4. Test — "Does it work?"
| Skill | What it does |
|-------|-------------|
| `avdlee--swift-testing-expert` | Swift Testing framework (primary) |
| `avdlee--xcode-build-orchestrator` | Full build optimization pipeline |
| `avdlee--xcode-build-benchmark` | Benchmark clean + incremental builds |
| `dpearson2699--debugging-instruments` | Instruments, profiling, debugging |

### 5. Deploy — "Ship it"
| Skill | What it does |
|-------|-------------|
| `truongduy2611--app-store-preflight` | Scan for rejection patterns before submit |
| `jordancoin--asc-cli` | App Store Connect CLI automation |
| `rudrankriyam--asc-release-flow` | Full release workflow |
| `rudrankriyam--asc-testflight-orchestration` | TestFlight beta management |
| `eronred--aso-audit` | App Store Optimization audit |

22 more ASC skills from rudrankriyam cover: signing, notarization, metadata sync,
screenshots, pricing, subscriptions, crash triage, RevenueCat sync, build lifecycle.
Pattern: `rudrankriyam--asc-{topic}`

### 6. Iterate — "Make it better"
| Skill | What it does |
|-------|-------------|
| `jordancoin--ralph-loop` | Autonomous iteration loop until done |
| `jordancoin--motioneyes` | Debug animations from real motion logs |
| `eronred--crash-analytics` | Crash analysis and triage |
| `eronred--retention-optimization` | User retention improvement |

## Cross-Cutting (any phase)
| Skill | What it does |
|-------|-------------|
| `jordancoin--xcodebuild-cli` | Build, test, run, debug via XcodeBuildMCP |
| `jordancoin--xcode-previews` | Capture SwiftUI previews for visual check |
| `jordancoin--apple-docs-mcp` | Apple Developer Documentation MCP |
| `harryworld--xcode-26` | Xcode 26, Liquid Glass, Foundation Models |

## Loading a Skill

Read the SKILL.md from the skills directory:
```
/path/to/ios-skills-collection/skills/{skill-id}/SKILL.md
```

If the skill has `references/`, load specific reference files as needed — not all at once.

## When Multiple Skills Cover the Same Topic

For overlapping domains, use the **primary** skill first. Fall back to others if you need
a different perspective:

| Domain | Primary | Alternatives |
|--------|---------|-------------|
| SwiftUI | twostraws--swiftui-pro | avdlee--swiftui-expert, jordancoin--swiftui-expert |
| Concurrency | twostraws--swift-concurrency-pro | jordancoin--swift-concurrency |
| Testing | avdlee--swift-testing-expert | jordancoin--swift-testing |
| Accessibility | dadederk--ios-accessibility | pasqualevittoriosi--swift-accessibility |
| Data | twostraws--swiftdata-pro | jordancoin--core-data (for Core Data specifically) |
| Build Optimization | avdlee--xcode-build-orchestrator | avdlee--xcode-build-fixer |
| ASO | eronred--aso-audit | rudrankriyam--asc-aso-audit |
