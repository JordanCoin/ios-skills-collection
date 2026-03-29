---
name: Swift Concurrency
description: Modern Swift concurrency with async/await, actors, TaskGroup, Sendable, and proper actor isolation for thread-safe iOS development
version: 1.0.0
---

# Swift Concurrency Skill

Master Swift 6 structured concurrency for safe, efficient concurrent code. Covers async/await, actors, tasks, and the Sendable protocol.

## async/await Fundamentals

### Basic Async Functions

```swift
// Async function declaration
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NetworkError.invalidResponse
    }

    return try JSONDecoder().decode(User.self, from: data)
}

// Calling async functions
func loadProfile() async {
    do {
        let user = try await fetchUser(id: "123")
        print("Loaded: \(user.name)")
    } catch {
        print("Error: \(error)")
    }
}
```

### Async Properties

```swift
struct RemoteImage {
    let url: URL

    var data: Data {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
    }
}
```

### Async Sequences

```swift
// Creating async sequences
func fetchPages() -> AsyncThrowingStream<Page, Error> {
    AsyncThrowingStream { continuation in
        Task {
            var cursor: String? = nil
            repeat {
                let response = try await fetchPage(cursor: cursor)
                for page in response.pages {
                    continuation.yield(page)
                }
                cursor = response.nextCursor
            } while cursor != nil
            continuation.finish()
        }
    }
}

// Consuming async sequences
func processPages() async throws {
    for try await page in fetchPages() {
        process(page)
    }
}
```

## Tasks

### Unstructured Tasks

```swift
// Fire-and-forget task (inherits actor context)
func startBackgroundWork() {
    Task {
        await performWork()
    }
}

// Detached task (no inherited context)
func startDetachedWork() {
    Task.detached(priority: .background) {
        await performHeavyWork()
    }
}
```

### Task Cancellation

```swift
func downloadWithCancellation() async throws -> Data {
    // Check for cancellation
    try Task.checkCancellation()

    // Or check manually
    if Task.isCancelled {
        throw CancellationError()
    }

    // Cooperative cancellation in loops
    for item in items {
        try Task.checkCancellation()
        await process(item)
    }

    return data
}

// Cancelling tasks
class DownloadManager {
    private var downloadTask: Task<Data, Error>?

    func startDownload() {
        downloadTask = Task {
            try await downloadLargeFile()
        }
    }

    func cancelDownload() {
        downloadTask?.cancel()
    }
}
```

### TaskGroup for Parallel Work

```swift
// Parallel fetching with TaskGroup
func fetchAllUsers(ids: [String]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        for id in ids {
            group.addTask {
                try await fetchUser(id: id)
            }
        }

        var users: [User] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}

// With result collection
func fetchWithResults(ids: [String]) async -> [Result<User, Error>] {
    await withTaskGroup(of: Result<User, Error>.self) { group in
        for id in ids {
            group.addTask {
                do {
                    return .success(try await fetchUser(id: id))
                } catch {
                    return .failure(error)
                }
            }
        }

        var results: [Result<User, Error>] = []
        for await result in group {
            results.append(result)
        }
        return results
    }
}
```

## Actors

### Basic Actor

```swift
actor BankAccount {
    private var balance: Double = 0

    func deposit(_ amount: Double) {
        balance += amount
    }

    func withdraw(_ amount: Double) throws {
        guard balance >= amount else {
            throw BankError.insufficientFunds
        }
        balance -= amount
    }

    func getBalance() -> Double {
        balance
    }
}

// Usage (requires await)
let account = BankAccount()
await account.deposit(100)
let balance = await account.getBalance()
```

### nonisolated Methods

```swift
actor DataStore {
    private var cache: [String: Data] = [:]

    // Requires isolation (default)
    func store(_ data: Data, for key: String) {
        cache[key] = data
    }

    // No isolation needed - can be called synchronously
    nonisolated var description: String {
        "DataStore instance"
    }

    // Computed from immutable state
    nonisolated let identifier = UUID()
}
```

### Actor Reentrancy

```swift
actor ImageLoader {
    private var cache: [URL: Image] = [:]
    private var inProgress: [URL: Task<Image, Error>] = [:]

    func load(from url: URL) async throws -> Image {
        // Check cache first
        if let cached = cache[url] {
            return cached
        }

        // Check if already loading
        if let existing = inProgress[url] {
            return try await existing.value
        }

        // Start new load
        let task = Task {
            let image = try await downloadImage(from: url)
            cache[url] = image
            inProgress[url] = nil
            return image
        }

        inProgress[url] = task
        return try await task.value
    }
}
```

## @MainActor

### UI Updates on Main Thread

```swift
@MainActor
final class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func loadUser(id: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            user = try await repository.fetch(id: id)
        } catch {
            self.error = error
        }
    }
}
```

### Calling MainActor from Background

```swift
actor DataProcessor {
    func process(items: [Item]) async {
        let results = heavyProcessing(items)

        // Switch to main actor for UI update
        await MainActor.run {
            UIManager.shared.updateUI(with: results)
        }
    }
}
```

## Sendable Protocol

### Understanding Sendable

```swift
// Value types are implicitly Sendable
struct Point: Sendable {
    var x: Double
    var y: Double
}

// Classes must be explicitly marked and thread-safe
final class Counter: Sendable {
    private let lock = NSLock()
    private var _count = 0

    var count: Int {
        lock.withLock { _count }
    }

    func increment() {
        lock.withLock { _count += 1 }
    }
}

// Actors are implicitly Sendable
actor SafeCounter: Sendable {
    var count = 0

    func increment() {
        count += 1
    }
}
```

### @unchecked Sendable

```swift
// Use when you guarantee thread safety manually
final class LegacyCache: @unchecked Sendable {
    private let queue = DispatchQueue(label: "cache.queue")
    private var storage: [String: Any] = [:]

    func get(_ key: String) -> Any? {
        queue.sync { storage[key] }
    }

    func set(_ key: String, value: Any) {
        queue.async { [self] in
            storage[key] = value
        }
    }
}
```

### Sendable Closures

```swift
actor DataManager {
    func process(completion: @Sendable @escaping () -> Void) {
        Task {
            await doWork()
            completion()
        }
    }
}
```

## Global Actors

### Custom Global Actors

```swift
@globalActor
actor DatabaseActor: GlobalActor {
    static let shared = DatabaseActor()
}

@DatabaseActor
final class DatabaseManager {
    private var connection: Connection?

    func query(_ sql: String) -> [Row] {
        // Runs on DatabaseActor
        connection?.execute(sql) ?? []
    }
}

// Usage
@DatabaseActor
func fetchRecords() async -> [Record] {
    let manager = DatabaseManager()
    return manager.query("SELECT * FROM records")
}
```

## Common Patterns

### Async Initialization

```swift
actor ConfiguredService {
    private var config: Config?

    func configure() async throws {
        config = try await loadConfig()
    }

    func performAction() async throws {
        guard let config else {
            throw ServiceError.notConfigured
        }
        // Use config
    }
}

// Factory pattern for async init
extension ConfiguredService {
    static func create() async throws -> ConfiguredService {
        let service = ConfiguredService()
        try await service.configure()
        return service
    }
}
```

### Timeout Pattern

```swift
func fetchWithTimeout<T>(
    seconds: Double,
    operation: @escaping () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(for: .seconds(seconds))
            throw TimeoutError()
        }

        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}

// Usage
let user = try await fetchWithTimeout(seconds: 10) {
    try await fetchUser(id: "123")
}
```

### Rate Limiting

```swift
actor RateLimiter {
    private let limit: Int
    private let interval: Duration
    private var requests: [Date] = []

    init(limit: Int, per interval: Duration) {
        self.limit = limit
        self.interval = interval
    }

    func acquire() async throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(-interval.timeInterval)
        requests = requests.filter { $0 > cutoff }

        if requests.count >= limit {
            let waitTime = requests.first!.timeIntervalSince(cutoff)
            try await Task.sleep(for: .seconds(waitTime))
            try await acquire()
        } else {
            requests.append(now)
        }
    }
}
```

## References

- See `references/migration-to-swift6.md` for Swift 6 strict concurrency migration
- See `references/concurrency-debugging.md` for debugging race conditions
