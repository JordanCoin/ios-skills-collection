# Migrating from ObservableObject to @Observable

## Overview

iOS 17+ introduced the `@Observable` macro as a simpler, more efficient replacement for `ObservableObject`. This guide covers the migration process.

## Key Differences

| Feature | ObservableObject | @Observable |
|---------|------------------|-------------|
| Property wrapper | `@Published` | None needed |
| View consumption | `@ObservedObject` / `@StateObject` | `@State` / direct reference |
| Binding creation | `$viewModel.property` | `@Bindable` + `$property` |
| Observation | Whole object | Per-property |
| Performance | Redraws on any change | Redraws only for used properties |

## Migration Steps

### Step 1: Replace Class Declaration

```swift
// Before
import Combine

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
}

// After
import SwiftUI

@Observable
final class UserViewModel {
    var user: User?
    var isLoading = false
}
```

### Step 2: Update View Property Wrappers

```swift
// Before
struct UserView: View {
    @StateObject private var viewModel = UserViewModel()
    // or
    @ObservedObject var viewModel: UserViewModel
}

// After
struct UserView: View {
    @State private var viewModel = UserViewModel()
    // or just
    var viewModel: UserViewModel
}
```

### Step 3: Update Bindings

```swift
// Before
struct FormView: View {
    @ObservedObject var viewModel: FormViewModel

    var body: some View {
        TextField("Name", text: $viewModel.name)
    }
}

// After
struct FormView: View {
    @Bindable var viewModel: FormViewModel

    var body: some View {
        TextField("Name", text: $viewModel.name)
    }
}
```

### Step 4: Handle Dependency Injection

```swift
// Before
struct ContentView: View {
    @StateObject private var viewModel: UserViewModel

    init(service: UserServiceProtocol) {
        _viewModel = StateObject(wrappedValue: UserViewModel(service: service))
    }
}

// After
struct ContentView: View {
    @State private var viewModel: UserViewModel

    init(service: UserServiceProtocol) {
        _viewModel = State(initialValue: UserViewModel(service: service))
    }
}
```

## Complete Example

### Before (ObservableObject)

```swift
import SwiftUI
import Combine

class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let repository: ProductRepository
    private var cancellables = Set<AnyCancellable>()

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func loadProducts() {
        isLoading = true
        repository.fetchProducts()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] products in
                self?.products = products
            }
            .store(in: &cancellables)
    }
}

struct ProductListView: View {
    @StateObject private var viewModel: ProductListViewModel

    init(repository: ProductRepository) {
        _viewModel = StateObject(wrappedValue: ProductListViewModel(repository: repository))
    }

    var body: some View {
        List(viewModel.products) { product in
            ProductRow(product: product)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .onAppear {
            viewModel.loadProducts()
        }
    }
}
```

### After (@Observable)

```swift
import SwiftUI

@Observable @MainActor
final class ProductListViewModel {
    var products: [Product] = []
    var isLoading = false
    var error: Error?

    private let repository: ProductRepositoryProtocol

    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await repository.fetchProducts()
        } catch {
            self.error = error
        }
    }
}

struct ProductListView: View {
    @State private var viewModel: ProductListViewModel

    init(repository: ProductRepositoryProtocol) {
        _viewModel = State(initialValue: ProductListViewModel(repository: repository))
    }

    var body: some View {
        List(viewModel.products) { product in
            ProductRow(product: product)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.loadProducts()
        }
    }
}
```

## Benefits of Migration

1. **Simpler syntax** - No `@Published` annotations needed
2. **Better performance** - Fine-grained observation per property
3. **Cleaner async/await** - No Combine boilerplate
4. **Automatic main actor** - `@MainActor` ensures UI updates on main thread
5. **No retain cycle risk** - No need for `[weak self]` with async/await
