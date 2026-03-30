# MotionEyes Observability Patterns

Use this reference to choose trace metrics and interpret logs for animation debugging.

## Metric Selection

Pick metrics that represent the user complaint directly.

- Fade/visibility issues:
  - `Trace.value("opacity", opacity)`
- Scale/size issues:
  - `Trace.value("scale", scale)`
  - `Trace.value("size", size)`
- Translation/path issues:
  - `Trace.value("offset", CGPoint(x: offset.width, y: offset.height))`
  - `Trace.value("position", CGPoint(x: position.x, y: position.y))`
- Layout/frame-driven issues:
  - `Trace.geometry("frame", properties: [.minX, .minY, .width, .height], space: .swiftUI(.global), source: .layout)`
- Visible on-screen movement issues:
  - `Trace.geometry("frameOnScreen", properties: [.minY], space: .screen, source: .presentation)`
- Scroll behavior issues:
  - `Trace.scrollGeometry("scrollMetrics")`
  - `Trace.scrollGeometry("scrollMetrics", properties: [.contentOffsetY, .visibleRectMinY, .visibleRectHeight])`

Prefer one to three focused metrics first; expand only if root cause remains unclear.

## Intent Mapping

Match geometry mode to what the user cares about:

- User-visible/on-screen motion: `Trace.geometry(..., space: .screen, source: .presentation)`
- Layout relationships/spacing: `Trace.geometry(..., space: .swiftUI(.global), source: .layout)`
- Local container relationships: `Trace.geometry(..., space: .swiftUI(.local), source: .layout)` or a named coordinate space

If the first geometry trace is flat but motion is visible, add the complementary geometry mode and compare.

## Direction and Coordinate Conventions

iOS coordinate space conventions:

- Increasing `x` means moving right.
- Increasing `y` means moving down.
- Decreasing `y` means moving up.

Interpret direction by checking the sign and trend of sampled values between `Start` and `End`.

## Timing Interpretation

Use MotionEyes markers to reason about timing:

- `Start` marks first detected change in a burst.
- `End` marks first stable tick after the burst.

Useful checks:

- Delay to motion: time from interaction trigger to first `Start`.
- Motion duration: time from `Start` to `End`.
- Early/late fade: compare `opacity` change window with expected interaction timeline.

## Relative Motion Comparisons

For "A should track B" issues:

1. Trace both objects using either `Trace.value` offsets or `Trace.geometry`.
2. Compare values at similar timestamps.
3. Validate expected relationship:
   - fixed delta (e.g., badge is always 12pt above card),
   - same direction and similar slope,
   - synchronized start and end windows.

Common mismatch signatures:

- Diverging deltas: follower drift.
- Opposite sign trend: moves in opposite direction.
- Delayed `Start`: lagging follower.
- Early `End`: follower stops too soon.

## Geometry Space and Source

`Trace.geometry` separates coordinate target from frame source:

- `space: .swiftUI(...)` + `source: .layout`
  - SwiftUI layout coordinates (good for container/sibling relationships).
- `space: .swiftUI(.local)` + `source: .layout`
  - Local container relationships within a view or named coordinate space.
- `space: .window` + `source: .layout`
  - Layout movement relative to window edges.
- `space: .screen` + `source: .presentation`
  - Visible rendered movement relative to physical screen.

If visual wiggle is present while SwiftUI layout is flat, add a second metric with `.screen + .presentation`.

## Scroll Geometry Interpretation

For scroll jump, drift, or restoration issues:

1. Place `Trace.scrollGeometry` on the `ScrollView` container.
2. Start with `contentOffsetY`, `visibleRectMinY`, and `visibleRectHeight`.
3. Compare values before navigation, during transition, and after return.

Common mismatch signatures:

- Offset discontinuity: sudden `contentOffsetY` jump after return.
- Visible rect mismatch: `visibleRectMinY` diverges from expected restoration point.
- Layout-vs-scroll desync: view frame metrics look stable while scroll metrics continue changing.

Scroll caveat: views inside a `ScrollView` can appear to move while layout frames remain stable. Use `Trace.scrollGeometry` and/or presentation geometry to capture visible motion.

## Log Reading Quick Guide

MotionEyes output patterns:

- Value line:
  - `[MotionEyes][View][Metric] key=value key=value`
- Marker line:
  - `[MotionEyes][View][Metric] -- Start timestamp --`
  - `[MotionEyes][View][Metric] -- End timestamp --`

Read logs in sequence for each metric:

1. Baseline value before change.
2. `Start`.
3. Sample evolution at configured FPS.
4. `End`.

## Trace Assertions

Use MotionEyes traces for assertions only when the trace metric maps directly to the thing the user cares about.

Keep these checks separate:

- Continuity:
  - Detect abrupt local jumps or freezes in a scalar trace.
  - Use `MotionSmoothness` on samples from one `Start` to `End` burst.
  - Interpret this as sampled-value continuity, not render-time frame pacing.
- Monotonicity or backtracking:
  - Use a separate assertion when the user cares whether a value reverses direction.
  - Do not expect `MotionSmoothness` to fail spring overshoot or brief reversals by itself.
- Timing:
  - Compare `Start`, `End`, and total duration against the expected interaction.

Assertion guidance:

- Extract one scalar component at a time, such as `opacity.value`, `offset.y`, or `frame.minY`.
- Prefer project-specific baselines over one global threshold.
- If sample count is low or timestamps are irregular, lower confidence and consider visual analysis instead.

## Minimal Instrumentation Template

```swift
import MotionEyes

AnimatedView()
    .motionTrace("Target Motion", fps: 30) {
        Trace.value("opacity", opacity)
        Trace.value("offset", CGPoint(x: offset.width, y: offset.height))
        Trace.geometry(
            "targetFrame",
            properties: [.minX, .minY, .width, .height],
            space: .swiftUI(.global),
            source: .layout
        )
        Trace.geometry(
            "targetFrameOnScreen",
            properties: [.minY, .height],
            space: .screen,
            source: .presentation
        )
        Trace.scrollGeometry(
            "scrollMetrics",
            properties: [.contentOffsetY, .visibleRectMinY, .visibleRectHeight]
        )
    }
```

Use semantic metric names so logs remain easy to map back to intent.
