---
name: xcode-previews
description: Build and capture SwiftUI previews for visual analysis. Use when you need to see rendered UI output, verify layouts, or inspect visual components. Supports Xcode projects, SPM packages, and standalone Swift files.
---

# Xcode Previews Skill

Build SwiftUI views and capture screenshots of their rendered output for visual analysis.

> **Source:** [Iron-Ham/XcodePreviews](https://github.com/Iron-Ham/XcodePreviews)

## Installation

```bash
git clone https://github.com/Iron-Ham/XcodePreviews.git ~/XcodePreviews
```

Optionally set `PREVIEW_BUILD_PATH` if installed elsewhere:
```bash
export PREVIEW_BUILD_PATH=/path/to/XcodePreviews
```

## Prerequisites

- macOS with Xcode installed
- iOS Simulator
- Swift toolchain (preview-tool auto-builds on first run)

## Usage

### Unified Preview (Auto-detects project type)

```bash
~/XcodePreviews/scripts/preview <path-to-file.swift> --output /tmp/preview.png
```

### Capture Current Simulator State

```bash
~/XcodePreviews/scripts/preview --capture-only --output /tmp/preview.png
```

### With Explicit Project

```bash
~/XcodePreviews/scripts/preview <file.swift> \
  --project <path.xcodeproj> \
  --output /tmp/preview.png
```

## Parameters

| Option | Description |
|--------|-------------|
| `--project <path>` | Xcode project file |
| `--workspace <path>` | Xcode workspace file |
| `--package <path>` | SPM Package.swift path |
| `--module <name>` | Target module (auto-detected) |
| `--simulator <name>` | Simulator name (default: iPhone 17 Pro) |
| `--output <path>` | Output screenshot path |
| `--verbose` | Show detailed build output |
| `--keep` | Keep temporary files after capture |

## How It Works

1. **Parses** the Swift file to extract `#Preview { }` content
2. **Injects** a temporary PreviewHost target into the project
3. **Builds** only the required modules (~3-4 seconds for cached builds)
4. **Launches** in simulator and captures screenshot
5. **Cleans up** the injected target

## Workflow for AI Agents

When asked to preview a SwiftUI view:

1. **Build and capture**: Run the preview script
2. **Read the image**: Load `/tmp/preview.png` 
3. **Analyze the UI**:
   - Layout structure and arrangement
   - Visual elements (buttons, text, images)
   - Styling (colors, fonts, spacing)
   - Issues (alignment, overflow, clipping)
4. **Report findings** and suggest improvements

## Error Handling

| Issue | Solution |
|-------|----------|
| No simulator booted | `~/XcodePreviews/scripts/sim-manager.sh boot "iPhone 17 Pro"` |
| Build failure | Show error, suggest fixes, offer retry |
| Resource bundle crash | Script auto-includes Tuist and common bundles |
| Missing imports | Add target module to imports |

## Example

```bash
# Preview a SwiftUI view
~/XcodePreviews/scripts/preview Sources/MyApp/ContentView.swift \
  --output /tmp/preview.png

# View the result
open /tmp/preview.png
```

## Integration

This skill pairs well with:
- **swiftui-expert** — Generate code, then verify visually
- **swift-testing** — Capture UI state for snapshot tests
- **core-data** — Preview views with mock data contexts
