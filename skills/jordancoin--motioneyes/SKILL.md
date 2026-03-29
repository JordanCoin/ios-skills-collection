---
name: motioneyes-animation-debug
description: Diagnose and fix SwiftUI animation and scroll behavior by temporarily instrumenting views with MotionEyes, capturing console traces over time, and comparing motion data to user intent. Use when users report bugs such as wrong direction, premature fade, timing or easing mismatch, unexpected movement, missing movement, incorrect relative movement between views, scroll jumps, scroll restoration drift, or content-offset desynchronization.
---

# MotionEyes Animation Debug

Agent-first SwiftUI motion observability system. Lets agents **read real motion values** from logs instead of guessing from code.

Source: [edwardsanchez/MotionEyes](https://github.com/edwardsanchez/MotionEyes)

## Overview

Use MotionEyes as temporary observability for SwiftUI animation debugging:
1. Instrument targeted values and geometry
2. Capture time-series logs
3. Compare observed motion against expected
4. Apply fixes, re-validate
5. Clean up all agent-added tracing

## When to Use

- Fade timing bugs
- Wrong direction/axis movement
- Timing or easing mismatch
- Unexpected movement (something moves when it shouldn't)
- Missing movement (nothing happens when it should)
- Relative motion bugs (two views should move together)
- Scroll jumps, restoration drift, content-offset desync

## Workflow

1. **Confirm** the complaint in measurable terms
2. **Locate** the target view and state values driving animation
3. **Integrate** MotionEyes if missing (Swift package)
4. **Add** temporary `.motionTrace(...)` instrumentation
5. **Run** and reproduce the issue
6. **Capture** logs (XcodeBuildMCP preferred, CLI fallback)
7. **Analyze** how values evolve vs expected behavior
8. **Fix** and rerun to verify
9. **Remove** only agent-added instrumentation

## Installation

Add the Swift package:
```swift
.package(url: "https://github.com/edwardsanchez/MotionEyes.git", from: "1.0.0")
```

## Instrumentation

### Value Tracing

```swift
import MotionEyes

struct CardView: View {
    @State private var opacity = 1.0
    @State private var offset = CGSize.zero

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .opacity(opacity)
            .offset(offset)
            .motionTrace("Card Motion", fps: 30) {
                Trace.value("opacity", opacity)
                Trace.value("offset", CGPoint(x: offset.width, y: offset.height))
            }
    }
}
```

### Geometry Tracing

```swift
.motionTrace("Card Frame", fps: 30) {
    Trace.geometry(
        "cardFrame",
        properties: [.minX, .minY, .width, .height],
        space: .swiftUI(.global),
        source: .layout
    )
}
```

**Geometry modes:**
- Layout in SwiftUI coords: `space: .swiftUI(.global), source: .layout`
- Window-relative: `space: .window, source: .layout`
- True on-screen movement: `space: .screen, source: .presentation`

### Scroll Geometry Tracing

```swift
ScrollView {
    content
}
.motionTrace("Chat Scroll", fps: 30) {
    Trace.scrollGeometry(
        "scrollMetrics",
        properties: [.contentOffsetY, .visibleRectMinY, .visibleRectHeight]
    )
}
```

## Log Capture

### With XcodeBuildMCP (preferred)

```
1. mcp__XcodeBuildMCP__session_show_defaults
2. mcp__XcodeBuildMCP__build_run_sim
3. mcp__XcodeBuildMCP__start_sim_log_cap (subsystemFilter: "MotionEyes")
4. Reproduce the animation
5. mcp__XcodeBuildMCP__stop_sim_log_cap
```

### CLI Fallback

```bash
xcrun simctl spawn booted log stream \
  --style compact \
  --level debug \
  --predicate 'subsystem == "MotionEyes"'
```

## Log Analysis

Log signatures:
- Value samples: `[MotionEyes][View][Metric] key=value ...`
- Change burst start: `[MotionEyes][View][Metric] -- Start timestamp --`
- Change burst end: `[MotionEyes][View][Metric] -- End timestamp --`

Analyze:
- **Direction:** sign and trend of values
- **Timing:** delta from trigger to Start/End
- **Shape:** monotonic, overshoot, reversals, oscillation
- **Relationship:** compare two traces over same window

## Cleanup Rules

After every debug run:
- Remove all agent-added MotionEyes instrumentation
- Keep pre-existing user-authored MotionEyes traces
- Remove agent-added `import MotionEyes` if no longer needed
- Confirm code compiles after cleanup

## Limitations

- `.transition` visual behavior not directly observable when no underlying value is exposed
