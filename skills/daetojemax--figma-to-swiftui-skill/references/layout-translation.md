# Figma Layout to SwiftUI Translation

Complete reference for translating Figma layout concepts into SwiftUI code.

## Auto Layout to Stacks

Figma Auto Layout is the closest analog to SwiftUI stacks. The translation is mostly 1:1, but edge cases exist.

### Direction

- Vertical auto layout -> VStack(alignment:, spacing:)
- Horizontal auto layout -> HStack(alignment:, spacing:)
- Wrap (horizontal with line break) -> No native SwiftUI equivalent. Use LazyVGrid with adaptive columns, or a custom FlowLayout.

### Alignment

Figma auto layout alignment maps to SwiftUI alignment:

Primary axis alignment (justify):
- Packed (start) -> Default stack behavior (no spacer)
- Packed (center) -> Wrap content in stack with Spacer() on both sides, or use .frame(maxWidth/Height: .infinity) with centered alignment
- Packed (end) -> Spacer() before content
- Space between -> Spacer() between each child element
- Space around / space evenly -> Not native; distribute with custom spacing or GeometryReader

Cross axis alignment:
- VStack: .leading, .center, .trailing
- HStack: .top, .center, .bottom, .firstTextBaseline, .lastTextBaseline

### Spacing (Gap)

Figma gap value maps directly to spacing parameter:
- gap: 12 -> VStack(spacing: 12) or HStack(spacing: 12)
- Mixed gaps between children -> Cannot use single spacing value. Use explicit Spacer().frame(height/width:) or padding between children.

### Padding

Figma padding maps to SwiftUI .padding():
- Uniform padding: 16 -> .padding(16)
- Horizontal 16, Vertical 12 -> .padding(.horizontal, 16).padding(.vertical, 12)
- Individual edges -> .padding(EdgeInsets(top:, leading:, bottom:, trailing:))
- Note: Figma uses left/right, SwiftUI uses leading/trailing for RTL support

### Sizing

Figma sizing modes:
- Fixed (width: 200) -> .frame(width: 200)
- Hug contents -> No modifier needed. SwiftUI views hug by default.
- Fill container -> .frame(maxWidth: .infinity) or .frame(maxHeight: .infinity)
- Fill with min/max -> .frame(minWidth:, maxWidth:, minHeight:, maxHeight:)

### Aspect Ratio

- Figma constraint "Preserve aspect ratio" -> .aspectRatio(width/height, contentMode: .fit) or .fill

## Absolute Positioning

Figma frames without auto layout use absolute (x, y) positioning.

- Prefer translating to stacks when the visual structure allows it
- When absolute positioning is necessary, use ZStack with .offset(x:, y:)
- For responsive absolute layouts, use GeometryReader (sparingly)
- Figma constraints (pin left, pin top, etc.) -> combine .frame() with alignment parameters in the parent

## Scroll

- Figma frame with "Clip content" + overflow -> ScrollView
- Vertical scroll -> ScrollView(.vertical) { VStack { ... } }
- Horizontal scroll -> ScrollView(.horizontal) { HStack { ... } }
- Both directions -> ScrollView([.vertical, .horizontal]) { ... }
- Paging -> ScrollView { LazyHStack { ... } }.scrollTargetBehavior(.paging)

## Common Patterns

### Card Layout
Figma: Frame (auto layout vertical, padding 16, corner radius 12, drop shadow, fill white)
SwiftUI:
```swift
VStack(alignment: .leading, spacing: 8) {
    // card content
}
.padding(16)
.background(Color.white)
.clipShape(RoundedRectangle(cornerRadius: 12))
.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
```

### List Item
Figma: Frame (auto layout horizontal, spacing 12, padding vertical 12 horizontal 16, fill container)
SwiftUI:
```swift
HStack(spacing: 12) {
    // list item content
}
.padding(.vertical, 12)
.padding(.horizontal, 16)
.frame(maxWidth: .infinity, alignment: .leading)
```

### Header with Back Button
Figma: Frame (auto layout horizontal, space between, padding 16)
SwiftUI: Prefer .navigationTitle() + .toolbar {} over custom header when possible. Custom header only if design is significantly non-standard.

### Bottom Safe Area Content
Figma: Frame pinned to bottom with padding
SwiftUI:
```swift
VStack {
    Spacer()
    content
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
}
.safeAreaInset(edge: .bottom) { ... }
// or use .toolbar(.bottomBar)
```
