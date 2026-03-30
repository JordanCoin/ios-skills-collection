---
name: figma-to-swiftui
description: "Translate Figma designs into production-ready SwiftUI code with 1:1 visual fidelity using the Figma MCP workflow. Trigger when the user provides Figma URLs or node IDs and wants iOS/SwiftUI implementation, asks to implement a design or component from Figma for an iOS app, or references Figma selections in the context of an Xcode/SwiftUI project. Also trigger when user asks to inspect Figma designs for iOS planning, fetch design tokens for SwiftUI, or convert Figma assets for Xcode. Requires a working Figma MCP server connection. Do NOT trigger for web/React implementations."
---

# Figma to SwiftUI Implementation Skill

Translate Figma nodes into production-ready SwiftUI views with pixel-perfect accuracy. Combines MCP integration rules with a structured implementation workflow for iOS projects.

## Prerequisites

- Figma MCP server must be connected and accessible
- User must provide a Figma URL, e.g.: https://www.figma.com/design/:fileKey/:fileName?node-id=3166-70147&m=dev
  - May include &m=dev or other query params — only node-id matters
  - :fileKey — path segment after /design/
  - node-id value — the specific component or frame to implement
- OR when using figma-desktop MCP: select a node directly in the Figma desktop app (no URL required)
- Xcode project with an established SwiftUI codebase (preferred)

## MCP Connection

If any MCP call fails because Figma MCP is not connected, pause and ask the user to configure it. See references/figma-mcp-setup.md for troubleshooting.

---

## Workflow

Follow these steps in order. Do not skip steps.

**Two modes:** If the user wants to build a new screen from scratch, follow all steps sequentially. If the user wants to adapt/update an existing screen to match a Figma design, follow Steps 1–5, then do Step 5b (Adaptation Audit) before Step 6. Step 5b ensures every difference between the existing code and the design is identified and addressed — this is where most mistakes happen during adaptation.

### Step 1 — Parse the Figma URL

Extract fileKey and nodeId from the URL.

Accepted URL patterns (with or without www.):
- figma.com/design/:fileKey/:fileName?node-id=...
- figma.com/file/:fileKey/:fileName?node-id=... (legacy, same behavior)

Parsing rules:
- fileKey: first path segment after /design/ or /file/
- nodeId: value of node-id query parameter. Always replace "-" with ":" (URLs use "3166-70147", MCP expects "3166:70147")
- Ignore all other query parameters (m=dev, t=..., page-id=..., etc.)
- Reject /proto/ and /board/ URLs — they are prototypes and FigJam boards, not implementable designs. Ask the user for a /design/ link instead.

When using figma-desktop MCP without a URL, tools automatically use the currently selected node. Only nodeId is needed; fileKey is inferred.

### Step 2 — Fetch Design Context

get_design_context(fileKey=":fileKey", nodeId="1-2", prompt="generate for iOS using SwiftUI")

The `prompt` parameter steers the default code output toward SwiftUI. You can also pass project-specific hints: `"use components from Components/"`, `"generate using my design system tokens"`.

Returns structured design data: layout, typography, colors, spacing, and a code representation. Even with an iOS prompt, treat the output as a design specification, not code to port.

For large/complex designs: If the response is truncated, first run get_metadata to get a node map, identify sections and child IDs, then fetch each section individually.

For multi-device designs: If Figma contains frames for different screen sizes (iPhone + iPad), fetch all device-specific frames, not just one. See references/responsive-layout.md for merging them into adaptive SwiftUI views.

### Step 3 — Capture Screenshot

get_screenshot(fileKey=":fileKey", nodeId="1-2")

This screenshot is the source of truth for visual validation throughout implementation.

### Step 4 — Fetch Design Tokens (if available)

get_variable_defs(fileKey=":fileKey", nodeId="1-2")

Returns colors, spacing, typography tokens. Map to the project's SwiftUI design system. See references/design-token-mapping.md.

### Step 5 — Download Assets

The `get_design_context` response includes download URLs (localhost) for image assets in the design. Download them during the active MCP session — URLs are ephemeral.

1. Identify assets in the `get_design_context` response (image fills, icons, illustrations)
2. For each asset, check SF Symbols first (see references/asset-handling.md)
3. Download remaining: `curl -o <filename> "<localhost-url>"`
4. For icons/nodes without download URLs, use `get_screenshot(fileKey, nodeId)` to export as PNG
5. Add to Asset Catalog — see references/asset-handling.md for Contents.json, scale variants, SVG setup

Asset rules:
- Do NOT import new icon packages unless the project already uses them
- Do NOT create placeholder images — always download actual assets
- Raster images: Asset Catalog (*.xcassets) with @1x/@2x/@3x variants
- Vector assets: SVG in Asset Catalog with Preserve Vector Data, or convert to SwiftUI Shape if simple

### Step 5b — Adaptation Audit (when modifying an existing screen)

When the user asks to adapt/update an existing screen to match a Figma design, perform a full element-by-element audit before writing any code. See **references/adaptation-workflow.md** for the complete process.

Key steps:
1. Read the existing code and all its subcomponents
2. Build a categorized diff checklist (ADD / UPDATE / REMOVE) with exact old → new values
3. Pay special attention to spacing — it's the most commonly missed difference
4. Present the checklist to the user and clarify unknowns before implementing
5. Apply all changes — do not skip items that seem minor

### Step 6 — Implement in SwiftUI

Before writing any code:

1. Run `get_code_connect_map(fileKey, nodeId)` to check if Figma components in the design already have mapped code components. If a mapping exists — use that code directly instead of building from scratch.
2. Inspect the project's dependencies (Package.swift, Podfile, .xcodeproj) and existing codebase for UI-related libraries and patterns. The project may use third-party solutions for things you would otherwise implement with native SwiftUI. Examples:
- Image loading: Kingfisher, SDWebImage, Nuke instead of AsyncImage
- Animations: Lottie instead of SwiftUI animations
- UI components: custom design system, SnapKit for layout, etc.
- Networking + image caching: Alamofire, custom image cache
- Charts: Charts library instead of Swift Charts

Use whatever the project already uses. Do not introduce native SwiftUI alternatives if the project has an established library for that purpose. If the design requires something the project has no dependency for, ask the user before choosing an approach.

Critical rule: MCP output (React + Tailwind) is a representation of design intent. Do NOT port React to SwiftUI. Read design properties and build native SwiftUI views from scratch.

Do NOT implement system-provided elements that appear in Figma mockups. Designers often include them for context, but they are rendered by iOS automatically. Skip these:
- Keyboard (system keyboard, emoji picker)
- Status bar (time, battery, signal)
- Home indicator bar
- Navigation bar back button (provided by NavigationStack)
- Tab bar if using native TabView (only implement custom tab bars)
- System alerts and action sheets (use .alert() / .confirmationDialog())
- Share sheet (use ShareLink or UIActivityViewController)
- System search bar (use .searchable())
- Pull-to-refresh indicator (use .refreshable())
- Page indicator dots for native TabView with .page style

If unsure whether an element is system-provided or custom, ask the user.

#### 6.1 — Layout Translation

See references/layout-translation.md for the complete mapping. Key rules:

Figma Auto Layout (vertical) -> VStack(spacing:) with matching alignment
Figma Auto Layout (horizontal) -> HStack(spacing:) with matching alignment
Figma Auto Layout with wrap -> LazyVGrid or custom FlowLayout
Figma Frame with absolute children -> ZStack + .offset() (avoid when possible)
Figma padding -> .padding(.horizontal, 16) edge-specific
Figma gap -> spacing parameter in stack initializer
Figma fill container -> .frame(maxWidth: .infinity)
Figma hug contents -> No frame modifier (intrinsic sizing, SwiftUI default)
Figma fixed size -> .frame(width:, height:)
Figma aspect ratio -> .aspectRatio(ratio, contentMode:)
Figma scroll -> ScrollView(.vertical) or .horizontal
Figma constraints (pin to edges) -> .frame() + alignment in parent
Figma frame sized for specific device -> Check if project supports multiple devices, adapt with size classes. See references/responsive-layout.md

#### 6.2 — Typography Translation

Figma font family -> Closest iOS system font or project custom font
Figma font weight -> Font.Weight (.regular, .medium, .semibold, .bold)
Figma font size -> .font(.system(size:, weight:, design:)) or custom Font extension
Figma line height -> .lineSpacing(lineHeight - fontSize)
Figma letter spacing -> .tracking() (Figma px = SwiftUI points, 1:1 on iOS)

If the project has a typography system (Typography.headline), prefer project tokens over raw values.

#### 6.3 — Color Translation

Figma hex color -> Color from Asset Catalog or Color(hex:) extension
Figma color + opacity -> .opacity() modifier or color with alpha
Figma linear gradient -> LinearGradient(colors:, startPoint:, endPoint:)
Figma radial gradient -> RadialGradient(colors:, center:, startRadius:, endRadius:)
Figma color variables -> Map to project tokens (Color.primaryText, Color.surface)
Figma dark mode variants -> Adaptive colors in Asset Catalog or @Environment(\.colorScheme)

When conflicts arise between project tokens and Figma specs, prefer project tokens but adjust minimally to match visuals.

#### 6.4 — Component Translation

Figma component instance -> Check for existing view in project. Reuse over creating new.
Figma button -> Button + project .buttonStyle()
Figma text input -> TextField or TextEditor
Figma toggle -> Toggle with custom style if design differs from system
Figma image -> Image from Asset Catalog for local. For remote URLs, use the project's image loading library; if none exists, ask the user.
Figma list/collection -> List or LazyVStack / LazyVGrid
Figma tab bar -> TabView or custom tab bar if non-standard
Figma navigation bar -> .navigationTitle() + .toolbar {} or custom header
Figma sheet/modal -> .sheet() / .fullScreenCover() — sheet manages own dismiss
Figma card -> Custom view + .background() + .clipShape(.rect(cornerRadius:)) + .shadow()
Figma component with variants -> Check variant properties, summarize detected variants, ask user which style approach to use, then implement. See references/component-variants.md for translating Figma variant properties (state, size, style, content toggles) into SwiftUI. Always ask the user which implementation approach they prefer before writing variant code.

#### 6.5 — Effects and Decorations

Figma drop shadow -> .shadow(color:, radius:, x:, y:)
Figma inner shadow -> .overlay() with shadow or custom shape stroke
Figma blur (layer) -> .blur(radius:)
Figma blur (background) -> .background(.ultraThinMaterial) or .regularMaterial
Figma corner radius -> .clipShape(.rect(cornerRadius:))
Figma individual corners -> UnevenRoundedRectangle(topLeadingRadius:, ...)
Figma border/stroke -> .overlay(RoundedRectangle(...).stroke(...))
Figma clip content -> .clipped() or .clipShape()
Figma mask -> .mask { ... }
Figma blend mode -> .blendMode()
Figma Liquid Glass (iOS 26+) -> .glassEffect() with appropriate shape

#### 6.6 — Animations and Transitions

Figma prototype connections define transitions between frames. Interpret them as navigation or state-change animations — not as literal animation specs.

Figma dissolve -> .opacity() + withAnimation(.easeInOut)
Figma move in / slide in -> .transition(.move(edge:)) or .offset()
Figma push -> NavigationStack push (system transition)
Figma smart animate -> withAnimation { } on state change, match property diffs (position, size, opacity)
Figma scroll animate -> ScrollView with .scrollTransition() or .animation() on offset

Common SwiftUI patterns:
- State-driven: `withAnimation(.spring) { showDetail = true }` + `.transition(.move(edge: .trailing))`
- Matched geometry: `matchedGeometryEffect(id:in:)` for shared element transitions between views
- Implicit: `.animation(.default, value: someState)` on the animating view

Rules:
- Check project dependencies for Lottie or other animation libraries — use them if present
- Do not over-animate. If Figma shows a transition only between screens (prototype link), implement it as navigation, not a custom animation
- If the design includes complex choreographed animations (multiple elements, sequenced timing), ask the user whether to implement fully or simplify
- Figma prototype delays and durations are hints, not exact specs — use standard iOS timing (.default, .spring) unless the user specifies otherwise

### Step 7 — Validate (on user request only)

Do NOT auto-validate. Before starting implementation (after Step 5), ask the user how they want to validate the result. Examples:
- Compare screenshot side-by-side in Xcode preview
- Run on simulator and compare manually
- Use snapshot testing
- No validation needed, trust the implementation

Proceed with whichever method the user chooses. If the user does not specify, skip validation entirely.

Reference checklist (share with user if they ask what to check):
- Layout: spacing, alignment, sizing
- Typography: font, size, weight, line height
- Colors: fills, strokes, backgrounds, text
- Assets: all icons/images present, no placeholders
- Interactive states: press, focus, disabled
- Dark mode (if Figma provides variants)
- Dynamic Type: text scales appropriately
- Safe areas: no content behind notch / home indicator
- Scroll behavior correct if design implies scrollable content

If deviating from Figma (accessibility, platform conventions, technical constraints), document why in comments.

### Step 8 — Register Code Connect Mappings

After creating reusable SwiftUI components that correspond to Figma components, register them:

add_code_connect_map(fileKey, nodeId, componentPath, componentName)

This links the Figma component to your code so future designs using the same component will reference the existing implementation instead of generating new code.

Only register components that are:
- Reusable (used in multiple places or likely to be reused)
- Stable (not a one-off screen-specific view)

---

## Handling Complex Designs

1. get_metadata to get the node tree
2. Identify major sections and child node IDs
3. Implement top-down: container first, then sections
4. get_design_context + get_screenshot per section
5. If user requested validation, validate per section, then full composition

## MCP Tools Reference

get_design_context: Design data + default code + asset download URLs. Use always, primary source.
get_metadata: Sparse node tree. Use for large designs, structure first.
get_screenshot: Visual reference PNG. Use always, validation truth.
get_variable_defs: Design tokens. Use when project has design system tokens.
get_code_connect_map: Existing code mappings. Use before creating components.
add_code_connect_map: Register new mappings. Use after creating reusable components.

## Key Principles

1. Never implement from assumptions. Always fetch context + screenshot first.
2. MCP output is a spec, not code. Read properties, build native SwiftUI.
3. Use what the project uses. Check dependencies and existing patterns before implementing anything. Do not introduce native alternatives if the project already has a library for that purpose.
4. Project tokens win. Prefer project tokens, adjust minimally for visual match.
5. Validate only when asked. Ask the user how they want to validate before implementing.
6. Prefer SF Symbols. Check before downloading custom icons. For cross-platform projects, list all icons with proposed matches and confirm each one with the user.
7. Platform conventions matter. iOS navigation, safe areas, Dynamic Type, accessibility are more important than pixel-perfect Figma replication.
