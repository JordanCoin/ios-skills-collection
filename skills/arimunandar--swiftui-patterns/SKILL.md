---
name: SwiftUI Patterns
description: Modern SwiftUI patterns for iOS 18+, including @Observable, navigation, state management, and view composition following SOLID principles
version: 1.0.0
---

# SwiftUI Patterns Skill

Master modern SwiftUI development with Swift 6 features, @Observable macro, NavigationStack, and architectural patterns that follow SOLID principles.

## State Management (iOS 18+ / Swift 6)

### @Observable Macro (Preferred over ObservableObject)

The `@Observable` macro is the modern way to create observable state in SwiftUI:

```swift
import SwiftUI

@Observable
final class UserViewModel {
    var user: User?
    var isLoading = false
    var errorMessage: String?

    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    @MainActor
    func loadUser(id: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            user = try await repository.fetch(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### State Property Wrappers

| Wrapper | Use Case | Scope |
|---------|----------|-------|
| `@State` | View-local primitive state | Single view |
| `@Binding` | Two-way connection to parent state | Parent-child |
| `@Bindable` | Two-way binding to @Observable property | With @Observable |
| `@Environment` | Dependency injection | Environment chain |
| `@Observable` | Shared mutable state (replaces @ObservableObject) | Across views |

### Using @Bindable with @Observable

```swift
@Observable
final class FormViewModel {
    var email = ""
    var password = ""
    var isValid: Bool {
        !email.isEmpty && password.count >= 8
    }
}

struct LoginForm: View {
    @Bindable var viewModel: FormViewModel

    var body: some View {
        Form {
            TextField("Email", text: $viewModel.email)
            SecureField("Password", text: $viewModel.password)
            Button("Login") { /* ... */ }
                .disabled(!viewModel.isValid)
        }
    }
}
```

## Navigation (NavigationStack)

### Type-Safe Navigation with Enums

```swift
enum AppRoute: Hashable {
    case userProfile(User.ID)
    case settings
    case orderDetail(Order)
    case checkout(Cart)
}

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .userProfile(let userId):
            UserProfileView(userId: userId)
        case .settings:
            SettingsView()
        case .orderDetail(let order):
            OrderDetailView(order: order)
        case .checkout(let cart):
            CheckoutView(cart: cart)
        }
    }
}
```

### Programmatic Navigation

```swift
struct ProductListView: View {
    @Binding var path: NavigationPath
    let products: [Product]

    var body: some View {
        List(products) { product in
            Button {
                path.append(AppRoute.productDetail(product.id))
            } label: {
                ProductRow(product: product)
            }
        }
    }

    func navigateToCheckout(cart: Cart) {
        path.append(AppRoute.checkout(cart))
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
```

## View Composition

### Extract Subviews (Single Responsibility)

```swift
// BAD: Monolithic view
struct OrderView: View {
    let order: Order

    var body: some View {
        VStack {
            // 100+ lines of UI code
        }
    }
}

// GOOD: Composed from smaller views
struct OrderView: View {
    let order: Order

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                OrderHeaderView(order: order)
                OrderItemsSection(items: order.items)
                OrderSummaryView(
                    subtotal: order.subtotal,
                    tax: order.tax,
                    total: order.total
                )
                OrderActionsView(order: order)
            }
            .padding()
        }
    }
}
```

### Reusable Components with ViewBuilder

```swift
struct Card<Content: View>: View {
    let title: String?
    @ViewBuilder let content: () -> Content

    init(title: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.headline)
            }
            content()
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// Usage
Card(title: "Order Summary") {
    LabeledContent("Subtotal", value: order.subtotal.formatted(.currency(code: "USD")))
    LabeledContent("Tax", value: order.tax.formatted(.currency(code: "USD")))
    Divider()
    LabeledContent("Total", value: order.total.formatted(.currency(code: "USD")))
        .bold()
}
```

### ViewModifiers for Reusable Styling

```swift
struct CardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: 2)
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = 12) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius))
    }
}

// Usage
Text("Hello")
    .cardStyle()
```

## SOLID Principles in SwiftUI

### Single Responsibility Principle

Each view should have one reason to change:

```swift
// View: Only presentation
struct UserListView: View {
    @State private var viewModel: UserListViewModel

    var body: some View {
        List(viewModel.users) { user in
            UserRow(user: user)
        }
        .task { await viewModel.loadUsers() }
    }
}

// ViewModel: Business logic and state
@Observable @MainActor
final class UserListViewModel {
    private let service: UserServiceProtocol
    var users: [User] = []

    init(service: UserServiceProtocol) {
        self.service = service
    }

    func loadUsers() async {
        users = (try? await service.fetchAll()) ?? []
    }
}
```

### Open/Closed Principle

Extend behavior without modifying existing code:

```swift
// Base button style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

// Extended without modifying original
struct LoadingButtonStyle: ButtonStyle {
    let isLoading: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            if isLoading {
                ProgressView()
                    .tint(.white)
            }
            configuration.label
        }
        .padding()
        .background(Color.accentColor)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .opacity(configuration.isPressed || isLoading ? 0.8 : 1)
    }
}
```

### Dependency Inversion Principle

Depend on abstractions via Environment:

```swift
// Protocol abstraction
protocol AnalyticsProtocol {
    func track(event: String, properties: [String: Any])
}

// Environment key
private struct AnalyticsKey: EnvironmentKey {
    static let defaultValue: AnalyticsProtocol = NoOpAnalytics()
}

extension EnvironmentValues {
    var analytics: AnalyticsProtocol {
        get { self[AnalyticsKey.self] }
        set { self[AnalyticsKey.self] = newValue }
    }
}

// Usage in view
struct ProductView: View {
    @Environment(\.analytics) private var analytics
    let product: Product

    var body: some View {
        Button("Buy") {
            analytics.track(event: "purchase", properties: ["product_id": product.id])
        }
    }
}

// Inject real or mock
ProductView(product: product)
    .environment(\.analytics, FirebaseAnalytics()) // Production
    .environment(\.analytics, MockAnalytics())     // Testing
```

## Performance Optimization

### Avoid Expensive Body Computations

```swift
// BAD: Expensive computation in body
var body: some View {
    let sortedItems = items.sorted { $0.date > $1.date } // Called on every render
    List(sortedItems) { item in
        ItemRow(item: item)
    }
}

// GOOD: Computed outside body or cached
@Observable
final class ItemListViewModel {
    var items: [Item] = []

    var sortedItems: [Item] {
        items.sorted { $0.date > $1.date }
    }
}
```

### Use `@Previewable` for Previews (iOS 18+)

```swift
#Preview {
    @Previewable @State var count = 0

    VStack {
        Text("Count: \(count)")
        Button("+1") { count += 1 }
    }
}
```

### Lazy Loading

```swift
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}

LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
    ForEach(products) { product in
        ProductCard(product: product)
    }
}
```

## References

- See `references/observable-migration.md` for ObservableObject to @Observable migration guide
- See `references/navigation-patterns.md` for advanced navigation patterns
- See `references/mvvm-architecture.md` for complete MVVM implementation
