# Migrating to Swift 6 Strict Concurrency

## Overview

Swift 6 enables strict concurrency checking by default. This guide covers common migration patterns.

## Enable Strict Concurrency Checking

### In Package.swift
```swift
.target(
    name: "MyTarget",
    swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
    ]
)
```

### In Xcode Build Settings
Set "Strict Concurrency Checking" to "Complete"

## Common Migration Patterns

### 1. Make Types Sendable

```swift
// Before: Compiler warning
class UserCache {
    var users: [User] = []
}

// After: Thread-safe actor
actor UserCache {
    var users: [User] = []

    func add(_ user: User) {
        users.append(user)
    }

    func getAll() -> [User] {
        users
    }
}
```

### 2. Mark @MainActor for UI Code

```swift
// Before
class ViewModel: ObservableObject {
    @Published var data: [Item] = []

    func load() async {
        data = try await fetchData()  // Warning: not on main actor
    }
}

// After
@MainActor
class ViewModel: ObservableObject {
    @Published var data: [Item] = []

    func load() async {
        data = try await fetchData()  // Safe: guaranteed main actor
    }
}
```

### 3. Fix Closure Captures

```swift
// Before: Non-sendable capture
class DataManager {
    var processor: DataProcessor

    func process() {
        Task {
            processor.run()  // Warning: capturing non-sendable
        }
    }
}

// After: Use actor or make Sendable
actor DataManager {
    var processor: DataProcessor

    func process() async {
        processor.run()  // Safe: actor-isolated
    }
}
```

### 4. Handle Delegates

```swift
// Before
class NetworkManager: URLSessionDelegate {
    // Warning: Non-sendable conformance
}

// After: Make thread-safe
final class NetworkManager: NSObject, URLSessionDelegate, @unchecked Sendable {
    private let lock = NSLock()
    // Thread-safe implementation
}

// Or use actor
actor NetworkHandler {
    nonisolated func urlSession(_ session: URLSession, ...) {
        Task { await handleResponse(...) }
    }
}
```

### 5. Global Variables

```swift
// Before
var globalCache = Cache()  // Warning: mutable global

// After: Actor-protected
actor GlobalState {
    static let shared = GlobalState()
    var cache = Cache()
}

// Or use nonisolated(unsafe) if you guarantee safety
nonisolated(unsafe) var legacyGlobal = Cache()
```

## Sendable Conformance Strategies

### Value Types
```swift
// Automatic for structs with Sendable properties
struct UserDTO: Sendable {
    let id: String
    let name: String
}
```

### Reference Types
```swift
// Option 1: Make immutable
final class Config: Sendable {
    let apiKey: String
    let baseURL: URL

    init(apiKey: String, baseURL: URL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
}

// Option 2: Use actor
actor MutableConfig {
    var apiKey: String
    var baseURL: URL
}

// Option 3: @unchecked with manual safety
final class ThreadSafeConfig: @unchecked Sendable {
    private let lock = NSLock()
    private var _apiKey: String

    var apiKey: String {
        get { lock.withLock { _apiKey } }
        set { lock.withLock { _apiKey = newValue } }
    }
}
```

## Gradual Migration

1. **Start with Warnings**: Set checking to "Targeted" first
2. **Fix Critical Paths**: Address warnings in core functionality
3. **Increase to Complete**: Enable full checking
4. **Update Dependencies**: Ensure third-party code is compatible
5. **Test Thoroughly**: Concurrency bugs may surface
