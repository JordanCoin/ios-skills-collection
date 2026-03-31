---
name: ios-skills-router
description: >
  Always use when working on any iOS, macOS, Swift, SwiftUI, Xcode, or Apple platform project.
  Routes to the correct specialized skills based on development phase and task context.
  This collection contains 210 skills from 28 authors covering the full iOS lifecycle.
---

# iOS Skills Router

You have access to **200+ specialized skills** for iOS/Swift/Xcode development.
Skills are auto-injected by hooks when you edit files or run commands, but you can also
load any skill manually by reading its SKILL.md.

## CRITICAL: Proactively Load Skills Before Coding

**Do NOT start coding without checking for relevant skills first.** This is the most
important instruction in this router.

Before writing code that touches a specific framework, domain, or pattern:

1. **Check imports** — if the file imports `MapKit`, `HealthKit`, `StoreKit`, etc.,
   READ `skills/dpearson2699--{framework}/SKILL.md` BEFORE writing code.
2. **Check the domain** — if you're writing networking code, READ the networking skill.
   If you're writing concurrency, READ the concurrency skill. Don't guess.
3. **Check third-party frameworks** — if the project uses Mapbox, Firebase, Supabase, etc.,
   check if there's a skill for it in the collection. `ls skills/ | grep {name}`.
4. **When in doubt, search** — `ls skills/ | grep -i {keyword}` to find relevant skills.

Skills are only useful if you READ them before coding. Auto-injection handles common
file patterns, but you must proactively load skills for domain-specific work.

## How Routing Works

1. **Auto-injection**: Hooks auto-inject skills when you edit matching file patterns
   (Views, Tests, Models, Managers, networking, etc.) or run commands (xcodebuild, swift test, asc).
2. **Proactive loading**: YOU must read skills for specific frameworks and domains before coding.
   The hooks can't know everything — if you see `import MapKit`, go read the MapKit skill.
3. **Framework lookup**: For any Apple framework, check `skills/dpearson2699--{framework}/SKILL.md`.
4. **Search**: `ls skills/ | grep -i {keyword}` to find skills by topic.

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
| `jordancoin--pencil-ios-design` | iOS Pencil MCP design workflow with HIG patterns |
| `dadederk--ios-accessibility` | VoiceOver, Dynamic Type, assistive tech |
| `pasqualevittoriosi--swift-accessibility` | WCAG 2.2, App Store Nutrition Labels |

### 3. Develop — "Build it"
**Core (auto-injected on .swift files):**
| Skill | What it does |
|-------|-------------|
| `twostraws--swiftui-pro` | SwiftUI best practices (primary) |
| `twostraws--swift-concurrency-pro` | async/await, actors, Sendable |
| `twostraws--swiftdata-pro` | SwiftData persistence |
| `martinlasek--swift-coding-guideline` | Swift coding conventions |
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
| `rudrankriyam--asc-cli-usage` | App Store Connect CLI automation |
| `rudrankriyam--asc-release-flow` | Full release workflow |
| `rudrankriyam--asc-testflight-orchestration` | TestFlight beta management |
| `eronred--aso-audit` | App Store Optimization audit |

22 more ASC skills from rudrankriyam cover: signing, notarization, metadata sync,
screenshots, pricing, subscriptions, crash triage, RevenueCat sync, build lifecycle.
Pattern: `rudrankriyam--asc-{topic}`

### 6. Iterate — "Make it better"
| Skill | What it does |
|-------|-------------|
| `jordancoin--ios-design-stack` | Invocable iOS design pipeline (design → review → build → iterate) |
| `edwardsanchez--motioneyes-animation-debug` | Debug animations from real motion logs |
| `eronred--crash-analytics` | Crash analysis and triage |
| `eronred--retention-optimization` | User retention improvement |

## Cross-Cutting (any phase)
| Skill | What it does |
|-------|-------------|
| `getsentry--xcodebuildmcp-cli` | Build, test, run, debug via XcodeBuildMCP |
| `iron-ham--xcode-preview-capture` | Capture SwiftUI previews for visual check |
| `kimsungwhee--apple-docs-mcp` | Apple Developer Documentation MCP |
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

## Using Skills (Injected or Manual)

**STOP AND READ before coding.** When you're about to work on a specific domain:

1. Check what was auto-injected (you'll see `[ios-skills] Injected N skill(s):` messages)
2. Search for additional relevant skills: `ls skills/ | grep -i {domain}`
3. READ the skill files before writing code — not after
4. Follow their patterns, don't just absorb them passively

**Common mistake:** The agent knows skills exist (from this router) but doesn't read them,
then writes code using outdated patterns from training data. The skills override your training
data. Read them first.

**Example:** You're about to write MapKit code.
- Auto-injection might not fire (file isn't named `*MapKit*.swift`)
- But you SHOULD: `Read skills/dpearson2699--mapkit/SKILL.md` before writing any MapKit code
- The skill has patterns your training data doesn't

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
| API Design | `erikote04--swift-api-design-guidelines-skill` | martinlasek--swift-coding-guideline |
| Build Optimization | `avdlee--xcode-build-orchestrator` | avdlee--xcode-build-fixer |
| ASO | `eronred--aso-audit` | timbroddin--app-store-aso-skill |
| Figma → SwiftUI | `daetojemax--figma-to-swiftui-skill` | jordancoin--pencil-ios-design |
| Simulator | `conorluddy--ios-simulator-skill` | getsentry--xcodebuildmcp-cli |
| Code Review | `dimillian--review-swarm` | arimunandar--code-review-checklist |
| Debugging | `dimillian--ios-debugger-agent` | dpearson2699--debugging-instruments |
