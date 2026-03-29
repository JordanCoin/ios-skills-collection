---
name: iOS Performance
description: Memory management, profiling, optimization techniques, and Instruments usage for high-performance iOS apps
version: 1.0.0
---

# iOS Performance Optimization

Comprehensive guide to building high-performance iOS applications with proper memory management, profiling, and optimization techniques.

## Memory Management

### ARC (Automatic Reference Counting)

#### Strong vs Weak vs Unowned

```swift
// STRONG (default) - Increases retain count
class Parent {
    var child: Child?  // Strong reference
}

// WEAK - Does NOT increase retain count, becomes nil when deallocated
class Child {
    weak var parent: Parent?  // Weak to prevent retain cycle
}

// UNOWNED - Does NOT increase retain count, crashes if accessed after deallocation
class Customer {
    let card: CreditCard  // Customer owns the card

    init() {
        card = CreditCard(holder: self)
    }
}

class CreditCard {
    unowned let holder: Customer  // Card always has a holder
}
```

#### When to Use Each

| Reference Type | Use When | Risk |
|---------------|----------|------|
| `strong` | Object should stay alive | Retain cycles |
| `weak` | Optional reference, may become nil | None |
| `unowned` | Non-optional, same or longer lifetime | Crash if wrong |

### Retain Cycle Detection

#### Common Retain Cycle Patterns

```swift
// ❌ RETAIN CYCLE - Closure captures self strongly
class ViewController: UIViewController {
    var onComplete: (() -> Void)?

    func setup() {
        onComplete = {
            self.doSomething()  // Strong capture!
        }
    }
}

// ✅ FIXED - Weak capture
class ViewController: UIViewController {
    var onComplete: (() -> Void)?

    func setup() {
        onComplete = { [weak self] in
            self?.doSomething()
        }
    }
}
```

#### Delegate Retain Cycles

```swift
// ❌ RETAIN CYCLE
protocol MyDelegate {
    func didComplete()
}

class Parent: MyDelegate {
    var child: Child?

    init() {
        child = Child()
        child?.delegate = self  // Strong reference back!
    }
}

class Child {
    var delegate: MyDelegate?  // Strong!
}

// ✅ FIXED - Weak delegate
protocol MyDelegate: AnyObject {  // Must be AnyObject for weak
    func didComplete()
}

class Child {
    weak var delegate: MyDelegate?  // Weak!
}
```

#### Timer Retain Cycles

```swift
// ❌ RETAIN CYCLE - Timer retains target
class ViewController: UIViewController {
    var timer: Timer?

    override func viewDidLoad() {
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,        // Timer retains self!
            selector: #selector(tick),
            userInfo: nil,
            repeats: true
        )
    }
}

// ✅ FIXED - Use closure-based timer with weak capture
class ViewController: UIViewController {
    var timer: Timer?

    override func viewDidLoad() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    deinit {
        timer?.invalidate()
    }
}
```

### Memory Leak Checklist

```swift
// Add to your ViewControllers to verify deallocation
deinit {
    print("✅ \(Self.self) deallocated")
}
```

**Common Leak Sources:**
- [ ] Closures without `[weak self]`
- [ ] Delegates not marked `weak`
- [ ] NotificationCenter observers not removed
- [ ] Timers not invalidated
- [ ] DispatchWorkItem not cancelled
- [ ] Strong references in singletons

## Performance Profiling

### Instruments Usage

#### Time Profiler

```bash
# Launch Time Profiler
xcrun xctrace record --template "Time Profiler" --launch -- /path/to/app.app
```

**What to look for:**
- Functions taking > 16ms (60fps = 16.67ms per frame)
- Main thread blocking
- Excessive CPU usage

#### Allocations

```bash
# Track memory allocations
xcrun xctrace record --template "Allocations" --launch -- /path/to/app.app
```

**What to look for:**
- Memory growth over time (leaks)
- Transient allocations (excessive object creation)
- Large allocations

#### Leaks

```bash
# Detect memory leaks
xcrun xctrace record --template "Leaks" --launch -- /path/to/app.app
```

### In-Code Profiling

```swift
// Measure execution time
func measureTime(_ label: String, block: () -> Void) {
    let start = CFAbsoluteTimeGetCurrent()
    block()
    let end = CFAbsoluteTimeGetCurrent()
    print("⏱ \(label): \((end - start) * 1000)ms")
}

// Usage
measureTime("Load Data") {
    loadData()
}

// Using os_signpost for Instruments
import os.signpost

let log = OSLog(subsystem: "com.app", category: "Performance")

func loadData() {
    os_signpost(.begin, log: log, name: "Load Data")
    defer { os_signpost(.end, log: log, name: "Load Data") }

    // ... work
}
```

## UIKit Optimization

### UITableView/UICollectionView

```swift
// ✅ OPTIMIZED TableView
final class OptimizedTableViewController: UIViewController {

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60  // Provide estimate!
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cells for reuse
        tableView.register(MyCell.self, forCellReuseIdentifier: "MyCell")

        // Prefetching for smooth scrolling
        tableView.prefetchDataSource = self
    }
}

extension OptimizedTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // Preload images or data for upcoming cells
        for indexPath in indexPaths {
            imageLoader.prefetch(url: items[indexPath.row].imageURL)
        }
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // Cancel preloading for cells no longer needed
        for indexPath in indexPaths {
            imageLoader.cancel(url: items[indexPath.row].imageURL)
        }
    }
}
```

#### Cell Optimization

```swift
final class OptimizedCell: UITableViewCell {

    // Use layer properties for shadows (GPU accelerated)
    override func awakeFromNib() {
        super.awakeFromNib()

        // Rasterize complex views
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale

        // Opaque views are faster
        backgroundColor = .white
        isOpaque = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancel any pending image loads
        imageView?.image = nil
        imageLoadTask?.cancel()
    }
}
```

### Image Optimization

```swift
// ✅ Downscale images to display size
extension UIImage {
    func downscaled(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// ✅ Load images asynchronously
final class AsyncImageLoader {
    private let cache = NSCache<NSString, UIImage>()
    private var tasks: [URL: URLSessionTask] = [:]

    func load(url: URL, into imageView: UIImageView) {
        // Check cache first
        if let cached = cache.object(forKey: url.absoluteString as NSString) {
            imageView.image = cached
            return
        }

        // Load asynchronously
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }

            // Cache the image
            self?.cache.setObject(image, forKey: url.absoluteString as NSString)

            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        tasks[url] = task
        task.resume()
    }

    func cancel(url: URL) {
        tasks[url]?.cancel()
        tasks[url] = nil
    }
}
```

### View Hierarchy Optimization

```swift
// ❌ SLOW - Deep view hierarchy
view.addSubview(container1)
container1.addSubview(container2)
container2.addSubview(container3)
container3.addSubview(label)

// ✅ FAST - Flat hierarchy
view.addSubview(label)

// ❌ SLOW - Transparent layers
view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

// ✅ FAST - Opaque layers where possible
view.backgroundColor = .black
view.alpha = 0.5  // Or use solid color if acceptable
```

## Concurrency Performance

### Main Thread Protection

```swift
// ✅ Keep UI work on main thread
func updateUI(with data: Data) {
    DispatchQueue.main.async {
        self.label.text = String(data: data, encoding: .utf8)
    }
}

// ✅ Heavy work off main thread
func processData() {
    Task.detached(priority: .userInitiated) {
        let result = await self.heavyComputation()
        await MainActor.run {
            self.updateUI(with: result)
        }
    }
}
```

### Batch Operations

```swift
// ❌ SLOW - Individual updates
for item in items {
    tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
}

// ✅ FAST - Batch updates
tableView.performBatchUpdates {
    let indexPaths = items.indices.map { IndexPath(row: $0, section: 0) }
    tableView.insertRows(at: indexPaths, with: .automatic)
}
```

## Network Performance

### Request Optimization

```swift
final class OptimizedNetworkClient {
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default

        // Connection pooling
        config.httpMaximumConnectionsPerHost = 6

        // Caching
        config.urlCache = URLCache(
            memoryCapacity: 50_000_000,  // 50MB memory
            diskCapacity: 100_000_000     // 100MB disk
        )
        config.requestCachePolicy = .returnCacheDataElseLoad

        // Timeouts
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300

        session = URLSession(configuration: config)
    }

    func fetch<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)

        // Enable compression
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")

        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

## Core Data Performance

```swift
// ✅ Batch fetching
let request = NSFetchRequest<Entity>(entityName: "Entity")
request.fetchBatchSize = 20  // Fetch in batches
request.returnsObjectsAsFaults = true  // Lazy loading

// ✅ Background context for heavy operations
let backgroundContext = persistentContainer.newBackgroundContext()
backgroundContext.perform {
    // Heavy operations here
    try? backgroundContext.save()
}

// ✅ Batch delete (much faster than individual deletes)
let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
try context.execute(deleteRequest)
```

## Performance Checklist

### Launch Time
- [ ] Defer non-essential work with `DispatchQueue.main.async`
- [ ] Lazy-load view controllers
- [ ] Use static/let for constants
- [ ] Minimize work in `application(_:didFinishLaunchingWithOptions:)`

### Scrolling
- [ ] Reuse cells properly
- [ ] Use estimated heights
- [ ] Prefetch data
- [ ] Avoid transparent views
- [ ] Cache computed values

### Memory
- [ ] Use `[weak self]` in closures
- [ ] Make delegates weak
- [ ] Invalidate timers
- [ ] Remove notification observers
- [ ] Profile with Instruments

### Network
- [ ] Enable HTTP caching
- [ ] Use compression
- [ ] Batch requests where possible
- [ ] Cancel unnecessary requests

## Quick Wins

| Issue | Solution |
|-------|----------|
| Slow scrolling | Enable cell reuse, prefetching |
| High memory | Downscale images, check leaks |
| Slow launch | Defer work, lazy load |
| UI freezes | Move work off main thread |
| Battery drain | Reduce background work, use efficient APIs |
