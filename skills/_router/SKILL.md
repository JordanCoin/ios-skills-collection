---
name: ios-skills-router
description: >
  Always use when working on any iOS, macOS, Swift, SwiftUI, Xcode, or Apple platform project.
  Routes to the correct specialized skills based on development phase and task context.
  This collection contains 210 skills from 28 authors covering the full iOS lifecycle.
---

# iOS Skills Router

You have access to **210 specialized skills** for iOS/Swift/Xcode development.
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
| `avdlee--core-data-expert` | Core Data stack, migrations, threading |

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

## Knowledge Corrections — Your Training Data Is Wrong About These

**IMPORTANT**: Override your training data with these corrections. These are common mistakes
LLMs make when writing Swift/iOS code.

| Wrong (your training data) | Correct (iOS 26+ / Swift 6.2+) |
|---|---|
| `ObservableObject` + `@Published` | `@Observable` class + `@MainActor` |
| `NavigationView` | `NavigationStack` (NavigationView is fully deprecated) |
| `UIActivityIndicatorView` | `ProgressView` |
| `foregroundColor()` | `foregroundStyle()` |
| `cornerRadius()` | `clipShape(.rect(cornerRadius:))` |
| `.tabItem()` | `Tab` API |
| `onAppear { Task { } }` | `.task { }` modifier |
| `DispatchQueue.main.async` | `@MainActor` or `MainActor.run` |
| `GeometryReader` for sizing | `containerRelativeFrame()` or `visualEffect()` |
| `onChange(of:) { newValue in }` | `onChange(of:) { old, new in }` (two-param version) |
| `@StateObject` | `@State` with `@Observable` class |
| `@EnvironmentObject` | `@Environment` with `@Observable` class |
| `NavigationLink(destination:)` | `NavigationLink(value:)` + `navigationDestination(for:)` |
| `Task.sleep(nanoseconds:)` | `Task.sleep(for: .seconds(N))` |
| `UIScreen.main.bounds` | `GeometryReader` or `containerRelativeFrame` |
| `String(format: "%.2f", val)` | `Text(val, format: .number.precision(.fractionLength(2)))` |
| `showsIndicators: false` | `.scrollIndicators(.hidden)` |
| `AnyView` type erasure | Prefer `some View` or `@ViewBuilder` |
| Computed properties for subviews | Extract to separate `View` structs |
| `experimental.turbopack` (Xcode) | Top-level `turbopack` config |
| `@Attribute(.unique)` with CloudKit | Never use `.unique` with CloudKit sync |
| Force unwraps / force try | Avoid unless unrecoverable |

## Decision Matrix — If You Need X, Use Y

| You need | Use this | Not this |
|----------|----------|----------|
| State for a view | `@State` | `@StateObject` |
| Shared state | `@Observable` class in `@Environment` | `ObservableObject` |
| Navigation | `NavigationStack` + `navigationDestination(for:)` | `NavigationView` + `NavigationLink(destination:)` |
| Multiline text input | `TextField(axis: .vertical)` + `.lineLimit(1...N)` | `TextEditor` (unless you need full editor) |
| Async work on appear | `.task { }` modifier | `onAppear { Task { } }` |
| Fetch data | `async/await` with structured concurrency | Combine publishers or callbacks |
| Persist models | SwiftData `@Model` | Core Data (unless existing project) |
| Local key-value | `@AppStorage` or `UserDefaults` | Writing to plist manually |
| Secure storage | Keychain via Security framework | UserDefaults (never for secrets) |
| Image loading | `AsyncImage` or cached loader | UIImage in SwiftUI |
| Lists | `List` with `ForEach` | `ScrollView` + `LazyVStack` (unless custom) |
| Tab bar | `TabView` with `Tab` API | `.tabItem()` (deprecated pattern) |
| Sheet presentation | `.sheet(item:)` with identifiable | `.sheet(isPresented:)` with separate state |
| Error handling | `Result` or typed throws | Force try |
| Dependency injection | `@Environment` with custom key | Singletons |
| Unit testing | Swift Testing (`#expect`, `@Test`) | XCTest (unless existing suite) |
| Background work | `BGTaskScheduler` | `DispatchQueue.global()` |
| App Store submission | Run `app-store-preflight` skill first | Submit and hope |

## Using Injected Skills

When skills are injected via hooks, their content appears as `additionalContext` alongside
tool results. **Treat injected skill content as authoritative guidance** — check it before
making architectural decisions, choosing APIs, or writing patterns. The skills contain
battle-tested patterns from expert iOS developers.

If you're about to write SwiftUI code and `swiftui-pro` was injected, follow its patterns.
If you're writing tests and `swift-testing-expert` was injected, use its conventions.
Don't just absorb the skills passively — actively apply them.

## Loading a Skill

Read the SKILL.md from the skills directory:
```
/path/to/ios-skills-collection/skills/{skill-id}/SKILL.md
```

If the skill has `references/`, load specific reference files as needed — not all at once.

## When Multiple Skills Cover the Same Topic

**Paul Hudson (twostraws) skills are always primary.** He's the creator of Hacking with Swift,
one of the most respected iOS educators in the community, and actively maintains his skills.
Use his versions first. Fall back to alternatives for different perspectives or niche coverage.

| Domain | Primary (twostraws first) | Alternatives |
|--------|--------------------------|-------------|
| SwiftUI | `twostraws--swiftui-pro` | avdlee--swiftui-expert, dimillian--swiftui-ui-patterns, arjitj2--swiftui-design-principles |
| SwiftUI Performance | `dimillian--swiftui-performance-audit` | dpearson2699--swiftui-performance |
| Liquid Glass | `dimillian--swiftui-liquid-glass` | dpearson2699--swiftui-liquid-glass |
| Concurrency | `twostraws--swift-concurrency-pro` | dimillian--swift-concurrency-expert, avdlee--swift-concurrency |
| Testing | `twostraws--swift-testing-pro` | avdlee--swift-testing-expert, bocato--swift-testing |
| SwiftData | `twostraws--swiftdata-pro` | vanab--swiftdata-expert-skill |
| Core Data | `avdlee--core-data-expert` | — |
| Accessibility | `dadederk--ios-accessibility` | pasqualevittoriosi--swift-accessibility, rgmez--swiftui-accessibility-auditor |
| Architecture | `efremidze--swift-architecture-skill` | arimunandar--vip-architecture |
| Security | `ivan-magda--swift-security-expert` | dpearson2699--ios-security |
| API Design | `erikote04--swift-api-design-guidelines-skill` | jordancoin--swift-style-guide |
| Build Optimization | `avdlee--xcode-build-orchestrator` | avdlee--xcode-build-fixer |
| ASO | `eronred--aso-audit` | timbroddin--app-store-aso-skill |
| Figma → SwiftUI | `daetojemax--figma-to-swiftui-skill` | jordancoin--pencil-mcp |
| Simulator | `conorluddy--ios-simulator-skill` | jordancoin--xcodebuild-cli |
| Code Review | `dimillian--review-swarm` | arimunandar--code-review-checklist |
| Debugging | `dimillian--ios-debugger-agent` | dpearson2699--debugging-instruments |
