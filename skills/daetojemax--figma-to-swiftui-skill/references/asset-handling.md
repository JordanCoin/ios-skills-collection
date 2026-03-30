# Asset Handling for iOS/SwiftUI

How to process Figma assets for use in Xcode projects.

## SF Symbols First

Before downloading any icon from Figma, check if an equivalent SF Symbol exists.

### When to use SF Symbol instead of Figma asset:
- Icon is a common UI element (arrow, chevron, gear, heart, share, plus, minus, checkmark, xmark, magnifyingglass, person, bell, etc.)
- Icon closely matches an SF Symbol with minor style differences
- Design does not require a brand-specific icon
- **Cross-platform caveat:** If the project targets multiple platforms (e.g., Skip for iOS + Android, KMP), do NOT silently default to SF Symbols. Instead, collect all icons from the design, present the user with a list of each icon alongside the proposed SF Symbol match, and ask them to approve or reject per icon. Some icons may need platform-agnostic alternatives (e.g., custom SVGs, Material Symbols). Only use SF Symbols for icons the user explicitly approves.

### When to use Figma asset:
- Brand/logo icons (app logos, company logos, social media logos)
- Highly custom or illustrated icons not in SF Symbols
- Icons with specific color treatments that SF Symbols cannot replicate
- Complex multi-color illustrations

### SF Symbol matching tips:
- Figma "arrow right" -> Image(systemName: "arrow.right")
- Figma "close" or "x" -> Image(systemName: "xmark")
- Figma "settings" or "gear" -> Image(systemName: "gearshape")
- Figma "search" -> Image(systemName: "magnifyingglass")
- Figma "user" or "profile" -> Image(systemName: "person")
- Figma "home" -> Image(systemName: "house")
- Figma "notification" or "bell" -> Image(systemName: "bell")
- Figma "menu" or "hamburger" -> Image(systemName: "line.3.horizontal")
- Search SF Symbols app for more: https://developer.apple.com/sf-symbols/

## Extracting Assets from MCP Response

`get_design_context` returns localhost download URLs for image assets in the design. These URLs are ephemeral — they only live while the MCP session is active. Download them immediately.

### What to look for in the response:
- Image fills on frames (photos, illustrations, backgrounds)
- Icons with raster content (not simple vector shapes)
- Assets marked for export in Figma

### What to download vs what to code:
- **Download:** Photos, illustrations, logos, complex multi-color icons, brand assets
- **Code:** Simple geometric shapes, single-color icons with SF Symbol equivalents, solid fills, gradients

### Downloading assets:
```bash
curl -o filename.png "http://localhost:PORT/path/to/asset"
```

Download each asset as soon as you extract the URL. If a URL returns an error or times out, the session may have expired — re-run `get_design_context` for fresh URLs.

### Fallback — get_screenshot for individual nodes:
If an asset has no download URL in the `get_design_context` response (e.g., a custom icon or illustration), use `get_screenshot(fileKey, nodeId)` targeting that specific node to export it as PNG.

## Raster Images (PNG, JPG)

### From Figma MCP localhost URL:
1. Download the image from the localhost URL provided by MCP
2. Generate @1x, @2x, @3x variants (if MCP provides only one size, use the highest resolution as @3x and scale down)
3. Add to the project's Asset Catalog (Assets.xcassets)
4. Create an imageset with all three scale variants
5. Use in SwiftUI: Image("assetName")

### Naming convention:
- Use kebab-case or camelCase matching project convention
- Prefix with context: "onboarding-hero", "profile-placeholder"
- Do not use spaces or special characters

### Asset Catalog structure:
```
Assets.xcassets/
  Images/
    onboarding-hero.imageset/
      onboarding-hero@1x.png
      onboarding-hero@2x.png
      onboarding-hero@3x.png
      Contents.json
```

### Contents.json for raster imageset:
```json
{
  "images": [
    { "filename": "asset-name@1x.png", "idiom": "universal", "scale": "1x" },
    { "filename": "asset-name@2x.png", "idiom": "universal", "scale": "2x" },
    { "filename": "asset-name@3x.png", "idiom": "universal", "scale": "3x" }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

### Generating scale variants with sips:
Use the downloaded image as @3x source (highest resolution). Scale down for @2x and @1x:
```bash
# Example: source is 300x300 for a 100pt asset
cp source.png asset-name@3x.png
sips -Z 200 source.png --out asset-name@2x.png
sips -Z 100 source.png --out asset-name@1x.png
```
The `-Z` flag scales to fit within NxN pixels while preserving aspect ratio.

## Vector Assets (SVG)

### From Figma MCP:
1. Download SVG from localhost URL
2. Add to Asset Catalog as SVG (single vector)
3. In Contents.json, set "preserves-vector-representation": true
4. Use in SwiftUI: Image("iconName").renderingMode(.template) for tintable icons

### Contents.json for SVG imageset:
```json
{
  "images": [
    { "filename": "icon-name.svg", "idiom": "universal" }
  ],
  "info": { "author": "xcode", "version": 1 },
  "properties": { "preserves-vector-representation": true }
}
```

### When to convert SVG to SwiftUI Shape:
- Very simple shapes (circle, rectangle, simple path with <5 control points)
- Icons that need to animate
- When you need fine control over stroke/fill at runtime

### SVG to Shape conversion:
```swift
struct CustomIcon: Shape {
    func path(in rect: CGRect) -> Path {
        // Convert SVG path data to SwiftUI Path
    }
}
```

Only convert simple SVGs. Complex SVGs should stay as Asset Catalog resources.

## Remote Images

If the design references images loaded from a URL (user avatars, feed content):

1. Check project dependencies (Package.swift, Podfile, .xcodeproj) for an existing image loading library (Kingfisher, SDWebImage, Nuke, etc.)
2. If found — use the project's library and follow its existing patterns in the codebase
3. If not found — ask the user which approach to use before implementing. Do not default to AsyncImage without confirmation.

Do NOT download remote images as local assets.

## Asset Rules Summary

1. SF Symbols first for standard UI icons
2. Download from MCP localhost URLs directly (no placeholders ever)
3. Raster images: @1x/@2x/@3x in Asset Catalog
4. Vector icons: SVG in Asset Catalog with Preserve Vector Data
5. Remote images: use project's image loading library, ask user if none found
6. Do NOT add new icon library dependencies
7. Match project naming conventions for all assets
