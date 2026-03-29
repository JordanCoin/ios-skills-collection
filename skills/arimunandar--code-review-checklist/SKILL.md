---
name: Code Review Checklist
description: Comprehensive code review guidelines for iOS/Swift covering architecture, performance, security, and best practices
version: 1.0.0
---

# Code Review Checklist

Comprehensive checklist for reviewing iOS/Swift code. Use this systematically to ensure thorough reviews.

## Quick Review Checklist

### Must Check (Every PR)
- [ ] **Compiles** - No build errors or warnings
- [ ] **Tests pass** - All existing tests green
- [ ] **No crashes** - No force unwraps in new code (`!`)
- [ ] **Memory safe** - Weak references where needed
- [ ] **Thread safe** - UI updates on main thread

### Should Check
- [ ] **Architecture** - Follows VIP+W pattern
- [ ] **Naming** - Clear, descriptive names
- [ ] **Tests** - New code has tests
- [ ] **Documentation** - Complex logic explained

---

## Detailed Review Categories

## 1. Architecture Compliance

### VIP+W Pattern

```
✅ CORRECT                          ❌ INCORRECT
─────────────────────────────────────────────────────────────
ViewController only displays        ViewController has business logic
Interactor orchestrates logic       Interactor makes API calls directly
Worker handles async operations     Worker knows about Presenter
Presenter formats for display       Presenter has business logic
Router handles navigation           Navigation in ViewController
```

**Review Questions:**
- [ ] Does ViewController only call `interactor?.methodName(request:)`?
- [ ] Does Interactor delegate async work to Worker?
- [ ] Does Presenter only format data, no business logic?
- [ ] Is navigation handled by Router only?
- [ ] Are all dependencies injected via Configurator?

### Protocol Usage

```swift
// ✅ GOOD - Protocol-based dependency
protocol UserServiceProtocol {
    func fetchUser(id: String) async throws -> User
}

class UserInteractor {
    private let service: UserServiceProtocol  // Abstraction

    init(service: UserServiceProtocol) {
        self.service = service
    }
}

// ❌ BAD - Concrete dependency
class UserInteractor {
    private let service = UserService()  // Concrete type
}
```

**Checklist:**
- [ ] Dependencies injected, not created internally
- [ ] Protocols defined for all dependencies
- [ ] No singletons accessed directly (inject instead)

---

## 2. Memory Management

### Retain Cycles

```swift
// ❌ RETAIN CYCLE
button.onTap = {
    self.handleTap()  // Strong capture
}

// ✅ FIXED
button.onTap = { [weak self] in
    self?.handleTap()
}
```

**Checklist:**
- [ ] Closures use `[weak self]` or `[unowned self]`
- [ ] Delegates are `weak`
- [ ] Timers are invalidated in `deinit`
- [ ] NotificationCenter observers removed
- [ ] No circular references between objects

### Memory Leaks Detection

```swift
// Add to ViewControllers during development
deinit {
    print("✅ \(Self.self) deallocated")
}
```

**Review for:**
- [ ] ViewControllers have `deinit` logging (development)
- [ ] Closures stored as properties use weak capture
- [ ] Parent-child relationships use weak for child→parent

---

## 3. Concurrency & Thread Safety

### Main Thread UI Updates

```swift
// ❌ WRONG - UI update from background
Task {
    let data = await fetchData()
    label.text = data.title  // Crash risk!
}

// ✅ CORRECT
Task {
    let data = await fetchData()
    await MainActor.run {
        label.text = data.title
    }
}

// ✅ ALSO CORRECT
@MainActor
func updateUI(with data: Data) {
    label.text = data.title
}
```

**Checklist:**
- [ ] UI updates on main thread/MainActor
- [ ] Heavy work on background thread
- [ ] No data races (use actors or locks)
- [ ] Proper async/await usage

### Actor Isolation

```swift
// ✅ GOOD - Actor for shared mutable state
actor UserCache {
    private var cache: [String: User] = [:]

    func get(_ id: String) -> User? {
        cache[id]
    }

    func set(_ user: User) {
        cache[user.id] = user
    }
}
```

---

## 4. Error Handling

### Proper Error Propagation

```swift
// ❌ BAD - Silent failure
func loadData() {
    do {
        let data = try fetchData()
        process(data)
    } catch {
        // Silent failure!
    }
}

// ❌ BAD - Force try
func loadData() {
    let data = try! fetchData()  // Crash if error
}

// ✅ GOOD - Proper handling
func loadData() {
    do {
        let data = try fetchData()
        process(data)
    } catch {
        presenter?.presentError(error)
    }
}
```

**Checklist:**
- [ ] No empty catch blocks
- [ ] No `try!` or `try?` without justification
- [ ] Errors propagated to user appropriately
- [ ] Network errors handled gracefully
- [ ] Offline state handled

### Result Type Usage

```swift
// ✅ GOOD - Explicit success/failure
func authenticate() async -> Result<User, AuthError> {
    do {
        let user = try await worker.login()
        return .success(user)
    } catch let error as AuthError {
        return .failure(error)
    } catch {
        return .failure(.unknown)
    }
}
```

---

## 5. Optionals & Safety

### Force Unwrapping

```swift
// ❌ DANGEROUS
let name = user.name!
let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!

// ✅ SAFE
guard let name = user.name else { return }

guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? MyCell else {
    fatalError("Cell not registered") // Explicit failure with message
}

// ✅ ALSO GOOD - Nil coalescing
let name = user.name ?? "Unknown"
```

**Checklist:**
- [ ] No `!` force unwraps (except IBOutlets)
- [ ] Guard statements for early returns
- [ ] Optional chaining used appropriately
- [ ] Nil coalescing for defaults

### Implicitly Unwrapped Optionals

```swift
// ❌ AVOID (except IBOutlets)
var viewModel: ViewModel!

// ✅ PREFER
var viewModel: ViewModel?  // Or make non-optional with proper init
```

---

## 6. Naming Conventions

### Swift Naming Guidelines

```swift
// ✅ GOOD NAMES
func fetchUser(byID id: String) -> User?
var isLoading: Bool
let maximumRetryCount = 3
class UserProfileViewController
protocol UserServiceProtocol

// ❌ BAD NAMES
func getUser(_ id: String) -> User?  // Missing label
var loading: Bool                      // Not a question
let MAX_RETRY = 3                      // Not camelCase
class UserProfileVC                    // Abbreviated
protocol UserServiceDelegate           // Wrong suffix for non-delegate
```

**Checklist:**
- [ ] Methods describe action (verbs): `fetchUser`, `updateProfile`
- [ ] Booleans read as questions: `isLoading`, `hasError`, `canSubmit`
- [ ] Constants in camelCase: `maximumCount`, not `MAX_COUNT`
- [ ] Types in PascalCase: `UserProfile`
- [ ] Protocols: `Protocol` suffix for abstractions, `Delegate` for delegates

### VIP+W Naming

| Component | Naming Pattern |
|-----------|---------------|
| ViewController | `LoginViewController` |
| Interactor | `LoginInteractor` |
| Presenter | `LoginPresenter` |
| Worker | `LoginWorker` |
| Router | `LoginRouter` |
| Models | `Login.Request`, `Login.Response`, `Login.ViewModel` |
| Protocols | `LoginDisplayLogic`, `LoginBusinessLogic` |

---

## 7. Performance

### Collection Operations

```swift
// ❌ SLOW - Multiple passes
let filtered = users.filter { $0.isActive }
let mapped = filtered.map { $0.name }
let sorted = mapped.sorted()

// ✅ FAST - Single pass with lazy
let result = users.lazy
    .filter { $0.isActive }
    .map { $0.name }
    .sorted()
```

**Checklist:**
- [ ] Large collections use `lazy` for chained operations
- [ ] `first(where:)` instead of `filter().first`
- [ ] `contains(where:)` instead of `filter().isEmpty == false`
- [ ] Avoid repeated array lookups in loops

### Image Handling

```swift
// ❌ BAD - Load full image for thumbnail
imageView.image = UIImage(named: "large_photo")

// ✅ GOOD - Downscale to display size
imageView.image = UIImage(named: "large_photo")?.downscaled(to: imageView.bounds.size)
```

**Checklist:**
- [ ] Images downscaled to display size
- [ ] Images loaded asynchronously
- [ ] Image caching implemented
- [ ] Large images not held in memory

---

## 8. Security

### Sensitive Data

```swift
// ❌ BAD - Hardcoded secrets
let apiKey = "sk_live_abc123"

// ✅ GOOD - From secure storage
let apiKey = KeychainService.shared.get("api_key")

// ❌ BAD - Logging sensitive data
print("User token: \(token)")

// ✅ GOOD - Masked logging
print("User authenticated successfully")
```

**Checklist:**
- [ ] No hardcoded API keys or secrets
- [ ] Sensitive data stored in Keychain
- [ ] No sensitive data in logs
- [ ] HTTPS for all network requests
- [ ] User input sanitized

### Data Protection

```swift
// ✅ GOOD - Secure file storage
let fileURL = try FileManager.default.url(
    for: .applicationSupportDirectory,
    in: .userDomainMask,
    appropriateFor: nil,
    create: true
)
try data.write(to: fileURL, options: .completeFileProtection)
```

---

## 9. Code Quality

### SOLID Principles

| Principle | Check |
|-----------|-------|
| **S**ingle Responsibility | Does this class/function do ONE thing? |
| **O**pen/Closed | Can behavior be extended without modification? |
| **L**iskov Substitution | Can subclasses replace base classes? |
| **I**nterface Segregation | Are protocols focused and minimal? |
| **D**ependency Inversion | Are we depending on abstractions? |

### Code Smells

- [ ] No methods > 30 lines
- [ ] No classes > 300 lines
- [ ] No more than 3 parameters per function
- [ ] No nested conditionals > 2 levels deep
- [ ] No duplicate code blocks

### Magic Numbers

```swift
// ❌ BAD
if retryCount > 3 { ... }
view.layer.cornerRadius = 8

// ✅ GOOD
private let maximumRetryCount = 3
private enum Layout {
    static let cornerRadius: CGFloat = 8
}

if retryCount > maximumRetryCount { ... }
view.layer.cornerRadius = Layout.cornerRadius
```

---

## 10. Testing

### Test Coverage

- [ ] New public methods have tests
- [ ] Edge cases covered (empty, nil, error)
- [ ] Interactor logic tested
- [ ] Presenter formatting tested
- [ ] Worker async operations tested

### Test Quality

```swift
// ✅ GOOD TEST - Clear naming, single assertion
func test_authenticate_withInvalidPassword_shouldReturnError() {
    // Arrange
    let request = Login.Request(email: "test@test.com", password: "wrong")
    mockWorker.result = .failure(.invalidCredentials)

    // Act
    sut.authenticate(request: request)

    // Assert
    XCTAssertTrue(mockPresenter.presentErrorCalled)
}

// ❌ BAD TEST - Multiple assertions, unclear name
func testLogin() {
    sut.authenticate(request: request)
    XCTAssertTrue(mockPresenter.called)
    XCTAssertEqual(mockPresenter.result, expected)
    XCTAssertFalse(mockPresenter.errorCalled)
}
```

---

## Review Comment Templates

### Request Changes

```
🔴 **Change Required**

[Description of issue]

**Current:**
```code```

**Suggested:**
```code```

**Reason:** [Why this change is needed]
```

### Suggestions

```
🟡 **Suggestion**

Consider [suggestion] because [reason].

This would [benefit].
```

### Questions

```
🔵 **Question**

Could you explain [specific part]?

I'm wondering about [concern].
```

### Approvals

```
🟢 **LGTM**

Looks good! Nice work on [specific positive aspect].
```

---

## Review Severity Levels

| Level | Icon | Meaning | Action |
|-------|------|---------|--------|
| Blocker | 🔴 | Must fix before merge | Requires changes |
| Warning | 🟡 | Should fix, can discuss | Suggestion |
| Info | 🔵 | FYI, question | Discussion |
| Praise | 🟢 | Good work | Approval |
