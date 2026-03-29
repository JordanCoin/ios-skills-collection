---
name: swift-style-guide
description: Swift coding style guidelines covering naming, mutation semantics, formatting, file organization, and import hygiene. Use for consistent Swift code style across projects.
---

# Swift Style Guide

Opinionated Swift coding guidelines for consistent, readable code. Based on [martinlasek/skills](https://github.com/martinlasek/skills).

## Agent Behavior Contract

1. Apply these rules automatically when writing Swift code
2. Keep changes minimal and scoped to the request
3. Verify all imports are present before finalizing
4. Never use underscores in Swift identifiers

## Core Rules

### Naming Conventions (Mandatory)

- **Types**: PascalCase (`UserProfile`, `MarkdownFileModel`)
- **Properties/Methods**: lowerCamelCase (`loadUserProfile`, `userName`)
- **No underscores**: Never use underscores in function or property names
- **Model suffix**: All model types must use `Model` suffix
- **Reserved term**: Never use `coordinator` for any identifier

### Mutation Semantics (Mandatory)

**Goal:** Make mutations obvious. Avoid hidden work on assignment.

1. **No-op mutator wrappers are forbidden**
   - Don't create `setX()`, `updateX()`, `applyX()` methods that only do assignment
   - If no real behavior exists, allow direct property assignment

2. **`private(set)` is conditional, not default**
   - Use only when mutation must be controlled by methods with real behavior
   - If assignment is plain state replacement, don't force wrapper methods

3. **App-authored property accessors/observers are forbidden**
   - No explicit `get`/`set` accessors
   - No `willSet`/`didSet` observers

4. **Computed properties are getter-only and pure**
   - Must not declare setters
   - Must not mutate state
   - Must not cause side effects (logging, I/O, persistence)

**Bad:**
```swift
private(set) var targetLanguage: TargetLanguage = .traditionalChinese

func setTargetLanguage(_ value: TargetLanguage) {
    targetLanguage = value
}
```

**Good:**
```swift
var targetLanguage: TargetLanguage = .traditionalChinese
```

### Import Hygiene (Mandatory)

Before finalizing, verify all needed imports are present. Do not assume transitive imports; add explicit imports so the file builds cleanly on its own.

### File Organization

- **Model/**: Only for data structs/classes representing app or domain models
- **Enum/**: All enums (enums are NOT models)
- **Store/**: Persistence adapters (e.g., `UserDefaults` wrappers)
- **Shared/**: Only for truly cross-feature primitives

### Enum Rules (Mandatory)

1. All enums must live in their own dedicated file
2. Place enum files under `Enum/` folder within the relevant feature
3. **Exception**: `UserDefaultsKeys` may be a single file with nested enums

**Enum spacing** — Always insert blank line between cases:

```swift
enum Foo {

    case a

    case b
}
```

### Formatting

**Multi-line calls** — One argument per line:
```swift
let data = try url.bookmarkData(
    options: .withSecurityScope,
    includingResourceValuesForKeys: nil,
    relativeTo: nil
)
```

**Multi-line if** — Opening brace on its own line:
```swift
if
    let url = try? URL(
        resolvingBookmarkData: data,
        options: [.withSecurityScope],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
    ),
    isValidFile(url: url)
{
    return url
}
```

**Prefer guard** — Over nested if when it reduces indentation:
```swift
guard
    let url = try? URL(
        resolvingBookmarkData: data,
        options: [.withSecurityScope],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
    ),
    isValidFile(url: url)
else {
    return nil
}

return url
```

### File Headers (Mandatory)

File doc comments must list a real human author and date:
```swift
// Created by Martin Lasek on 18/01/2026.
```

When creating new files, set date to current date. Preserve existing human authorship.

## Quick Checklist

- [ ] No underscores in identifiers
- [ ] Model types have `Model` suffix
- [ ] Enums in dedicated files under `Enum/`
- [ ] No `coordinator` naming
- [ ] No no-op setter wrappers
- [ ] No `willSet`/`didSet` observers
- [ ] All imports explicit
- [ ] Blank lines between enum cases
- [ ] Multi-line formatting for long calls
