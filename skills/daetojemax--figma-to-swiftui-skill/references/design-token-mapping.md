# Figma Design Tokens to SwiftUI Mapping

How to translate Figma variables (from get_variable_defs) into a SwiftUI design system.

## Color Tokens

Figma color variables map to SwiftUI Color extensions or Asset Catalog named colors.

### Strategy

1. Check if project already has a color system (Color+Extensions.swift, Theme.swift, or Asset Catalog named colors)
2. If yes: map Figma variable names to existing project colors by matching values
3. If no: create Color extensions or Asset Catalog entries from Figma variables

### Mapping Rules

Figma variable "primary/500" -> Color.primary500 or Color("primary500")
Figma variable "text/primary" -> Color.textPrimary
Figma variable "surface/default" -> Color.surfaceDefault
Figma variable "border/subtle" -> Color.borderSubtle

### Adaptive Colors (Light/Dark)

Figma variables with mode variants (light/dark):
- Asset Catalog: Create color set with Any Appearance + Dark Appearance
- Code: Use @Environment(\.colorScheme) only if Asset Catalog is not an option

```swift
// Asset Catalog approach (preferred)
Color("textPrimary") // automatically adapts

// Code approach (when needed)
extension Color {
    static var textPrimary: Color {
        Color("textPrimary")
    }
}
```

## Spacing Tokens

Figma spacing variables map to CGFloat constants.

```swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}
```

Use project's existing spacing system if one exists. Do not create a parallel system.

## Typography Tokens

Figma typography variables map to Font definitions.

```swift
extension Font {
    static let headingLarge = Font.system(size: 28, weight: .bold)
    static let headingMedium = Font.system(size: 22, weight: .semibold)
    static let bodyRegular = Font.system(size: 16, weight: .regular)
    static let bodySmall = Font.system(size: 14, weight: .regular)
    static let caption = Font.system(size: 12, weight: .medium)
}
```

### Custom Fonts

If Figma uses a custom font (e.g., Inter, SF Pro Rounded):
1. Check if font is already added to the Xcode project (Info.plist UIAppFonts)
2. If not, download and add the font files
3. Use Font.custom("FontName", size:) instead of .system()

### Dynamic Type Support

Always consider Dynamic Type. Prefer .font(.headline) or .font(.body) when Figma typography maps closely to iOS text styles. For custom sizes, use @ScaledMetric:

```swift
@ScaledMetric(relativeTo: .body) private var fontSize: CGFloat = 16
```

## Border Radius Tokens

Figma corner radius variables map to CGFloat constants used with RoundedRectangle:

```swift
enum CornerRadius {
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
    static let full: CGFloat = 9999 // pill shape -> Capsule()
}
```

When radius equals 9999 or "full", use Capsule() instead of RoundedRectangle.

## Shadow Tokens

Figma shadow variables (elevation levels):

```swift
extension View {
    func shadowSm() -> some View {
        shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    func shadowMd() -> some View {
        shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    func shadowLg() -> some View {
        shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}
```

## General Rules

1. Always check project for existing design system before creating new tokens
2. Match by value first (hex color, px value), then by semantic name
3. If project tokens exist but names differ from Figma, use project names
4. Do not duplicate: one source of truth for each token
5. Group tokens logically (Color, Spacing, Typography, Radius, Shadow)
