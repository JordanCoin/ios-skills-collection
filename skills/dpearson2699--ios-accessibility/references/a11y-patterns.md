# Accessibility Patterns Reference

## Contents
- Labels, Values, and Hints
- Traits and Element Grouping
- Custom Controls and Adjustable Actions
- Focus Management Patterns
- Dynamic Type and Layout
- Custom Rotors
- System Accessibility Preferences
- UIKit Accessibility Patterns
- Common Mistakes Checklist

## Labels, Values, and Hints

```swift
Button(action: { }) {
    Image(systemName: "heart.fill")
}
.accessibilityLabel("Favorite")

Slider(value: $volume, in: 0...100)
    .accessibilityValue("\(Int(volume)) percent")

Button("Submit")
    .accessibilityHint("Submits the form and sends your feedback")
```

## Traits and Element Grouping

```swift
// Add traits without overwriting defaults
Button("Go") { }
    .accessibilityAddTraits(.updatesFrequently)

// Group children into a single accessibility element
HStack {
    Image(systemName: "person.circle")
    VStack {
        Text("John Doe")
        Text("Engineer")
    }
}
.accessibilityElement(children: .combine)
```

## Custom Controls and Adjustable Actions

```swift
HStack { /* custom star rating UI */ }
    .accessibilityElement()
    .accessibilityLabel("Rating")
    .accessibilityValue("\(rating) out of 5 stars")
    .accessibilityAdjustableAction { direction in
        switch direction {
        case .increment: if rating < 5 { rating += 1 }
        case .decrement: if rating > 1 { rating -= 1 }
        @unknown default: break
        }
    }
```

## Focus Management Patterns

```swift
@AccessibilityFocusState private var focusOnTrigger: Bool

Button("Open Settings") { showSheet = true }
    .accessibilityFocused($focusOnTrigger)
    .sheet(isPresented: $showSheet) {
        SettingsSheet()
            .onDisappear {
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(100))
                    focusOnTrigger = true
                }
            }
    }
```

```swift
enum A11yFocus: Hashable { case nameField, emailField, submitButton }
@AccessibilityFocusState private var focus: A11yFocus?
```

## Dynamic Type and Layout

```swift
@ScaledMetric(relativeTo: .title) private var iconSize: CGFloat = 24
@Environment(\.dynamicTypeSize) var dynamicTypeSize

var body: some View {
    if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading) { icon; textContent }
    } else {
        HStack { icon; textContent }
    }
}
```

## Custom Rotors

```swift
List(items) { item in ItemRow(item: item) }
    .accessibilityRotor("Unread") {
        ForEach(items.filter { !$0.isRead }) { item in
            AccessibilityRotorEntry(item.title, id: item.id)
        }
    }
```

## System Accessibility Preferences

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion
@Environment(\.accessibilityReduceTransparency) var reduceTransparency
@Environment(\.colorSchemeContrast) var contrast
@Environment(\.legibilityWeight) var legibilityWeight
```

## UIKit Accessibility Patterns

```swift
customButton.accessibilityTraits.insert(.button)
customButton.accessibilityTraits.remove(.staticText)

UIAccessibility.post(notification: .announcement, argument: "Upload complete")
UIAccessibility.post(notification: .layoutChanged, argument: targetView)
UIAccessibility.post(notification: .screenChanged, argument: newScreenView)
```

## Common Mistakes Checklist

- Direct trait assignment instead of `.accessibilityAddTraits`
- Missing focus restoration after dismissing sheets
- Ungrouped list rows creating excessive swipe stops
- Icon-only buttons missing labels
- Ignoring Reduce Motion, Reduce Transparency, or Increase Contrast
- Fixed font sizes that break Dynamic Type
- Tap targets smaller than 44x44 points
