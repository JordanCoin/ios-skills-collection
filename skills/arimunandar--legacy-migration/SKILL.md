---
name: Legacy to VIP+W Migration
description: Step-by-step guide for refactoring legacy/spaghetti iOS code to VIP+W Clean Architecture
version: 1.0.0
---

# Legacy to VIP+W Migration Guide

A systematic approach to refactoring legacy iOS codebases (MVC, Massive ViewController, spaghetti code) to VIP+W Clean Architecture.

## Migration Philosophy

### Golden Rules

1. **Never rewrite from scratch** - Incremental migration preserves working code
2. **One screen at a time** - Migrate scene by scene, not all at once
3. **Tests first** - Write tests for existing behavior before refactoring
4. **Keep it working** - App should work after each migration step
5. **Strangler pattern** - New code in VIP+W, gradually replace old code

### Migration Priority

Start with screens that are:
1. **Frequently changed** - High ROI for clean architecture
2. **Bug-prone** - Messy code causes bugs
3. **Well-understood** - You know the expected behavior
4. **Isolated** - Fewer dependencies on other screens

## Phase 1: Analysis

### Step 1.1: Identify the Mess

Common legacy patterns to identify:

```swift
// 🍝 SPAGHETTI: Everything in ViewController
class ProductViewController: UIViewController {
    // UI + Business Logic + Networking + Navigation ALL HERE

    func loadProduct() {
        // Direct API call in ViewController
        URLSession.shared.dataTask(with: url) { data, _, _ in
            let product = try? JSONDecoder().decode(Product.self, from: data!)

            DispatchQueue.main.async {
                // UI update mixed with business logic
                self.titleLabel.text = product?.name
                self.priceLabel.text = "$\(product?.price ?? 0)"

                if product?.isOnSale == true {
                    self.priceLabel.textColor = .red
                    self.saveBadge.isHidden = false
                }

                // Navigation logic here too
                if product == nil {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }.resume()
    }

    @IBAction func buyTapped() {
        // More API calls, validation, navigation...
    }
}
```

### Step 1.2: Document Current Behavior

Before refactoring, document:

```markdown
## ProductViewController Analysis

### Responsibilities (Current)
1. Display product details
2. Fetch product from API
3. Format price with currency
4. Show/hide sale badge
5. Handle buy action
6. Navigate back on error
7. Add to cart

### API Calls
- GET /products/{id}
- POST /cart/items

### Navigation
- Pop on error
- Push to checkout on buy

### State
- product: Product?
- isLoading: Bool
- cartItems: [CartItem]

### Side Effects
- Analytics tracking
- Local cart storage
```

### Step 1.3: Write Characterization Tests

Capture existing behavior before changing anything:

```swift
// Test existing behavior (even if messy)
final class ProductViewControllerLegacyTests: XCTestCase {

    func test_loadProduct_displaysProductName() {
        // Given
        let sut = ProductViewController()
        let mockProduct = Product(name: "Test", price: 99.99)
        // Inject mock somehow...

        // When
        sut.loadView()
        sut.viewDidLoad()

        // Then
        XCTAssertEqual(sut.titleLabel.text, "Test")
    }

    func test_loadProduct_onSale_showsSaleBadge() {
        // Capture current behavior
    }
}
```

## Phase 2: Extract Components

### Step 2.1: Create VIP+W File Structure

```bash
mkdir -p Features/Product
touch Features/Product/ProductViewController.swift
touch Features/Product/ProductInteractor.swift
touch Features/Product/ProductPresenter.swift
touch Features/Product/ProductWorker.swift
touch Features/Product/ProductRouter.swift
touch Features/Product/ProductModels.swift
touch Features/Product/ProductConfigurator.swift
```

### Step 2.2: Define Protocols First

```swift
// ProductModels.swift
enum Product {

    enum FetchProduct {
        struct Request {
            let productId: String
        }

        struct Response {
            let result: Result<ProductEntity, ProductError>
        }

        struct ViewModel {
            let title: String
            let formattedPrice: String
            let showSaleBadge: Bool
            let saleBadgeText: String?
        }
    }

    enum AddToCart {
        struct Request {
            let quantity: Int
        }

        struct Response {
            let result: Result<Void, CartError>
        }

        struct ViewModel {
            let message: String
            let isSuccess: Bool
        }
    }
}
```

```swift
// Protocols
protocol ProductDisplayLogic: AnyObject {
    func displayProduct(viewModel: Product.FetchProduct.ViewModel)
    func displayAddToCartResult(viewModel: Product.AddToCart.ViewModel)
    func displayLoading(isLoading: Bool)
    func displayError(message: String)
}

protocol ProductBusinessLogic {
    func fetchProduct(request: Product.FetchProduct.Request)
    func addToCart(request: Product.AddToCart.Request)
}

protocol ProductPresentationLogic {
    func presentProduct(response: Product.FetchProduct.Response)
    func presentAddToCartResult(response: Product.AddToCart.Response)
    func presentLoading(isLoading: Bool)
    func presentError(_ error: Error)
}

protocol ProductWorkerLogic {
    func fetchProduct(id: String) async throws -> ProductEntity
    func addToCart(productId: String, quantity: Int) async throws
}

protocol ProductRoutingLogic {
    func routeToCheckout()
    func routeBack()
}
```

### Step 2.3: Extract Worker (Network/Data)

Move API calls from ViewController to Worker:

```swift
// BEFORE (in ViewController)
URLSession.shared.dataTask(with: url) { data, _, _ in
    let product = try? JSONDecoder().decode(Product.self, from: data!)
    // ...
}

// AFTER (in Worker)
final class ProductWorker: ProductWorkerLogic {

    private let apiClient: APIClientProtocol
    private let cartStorage: CartStorageProtocol

    init(
        apiClient: APIClientProtocol = APIClient.shared,
        cartStorage: CartStorageProtocol = CartStorage.shared
    ) {
        self.apiClient = apiClient
        self.cartStorage = cartStorage
    }

    func fetchProduct(id: String) async throws -> ProductEntity {
        let endpoint = ProductEndpoint.getProduct(id: id)
        return try await apiClient.request(endpoint)
    }

    func addToCart(productId: String, quantity: Int) async throws {
        let endpoint = CartEndpoint.addItem(productId: productId, quantity: quantity)
        try await apiClient.request(endpoint)
        cartStorage.addItem(productId: productId, quantity: quantity)
    }
}
```

### Step 2.4: Extract Presenter (Formatting)

Move formatting logic from ViewController to Presenter:

```swift
// BEFORE (in ViewController)
self.priceLabel.text = "$\(product?.price ?? 0)"
if product?.isOnSale == true {
    self.priceLabel.textColor = .red
}

// AFTER (in Presenter)
final class ProductPresenter: ProductPresentationLogic {

    weak var viewController: ProductDisplayLogic?

    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter
    }()

    func presentProduct(response: Product.FetchProduct.Response) {
        let viewModel: Product.FetchProduct.ViewModel

        switch response.result {
        case .success(let product):
            viewModel = Product.FetchProduct.ViewModel(
                title: product.name,
                formattedPrice: formatPrice(product.price, isOnSale: product.isOnSale),
                showSaleBadge: product.isOnSale,
                saleBadgeText: product.isOnSale ? "SALE \(product.discountPercent)% OFF" : nil
            )

        case .failure(let error):
            presentError(error)
            return
        }

        viewController?.displayProduct(viewModel: viewModel)
    }

    private func formatPrice(_ price: Decimal, isOnSale: Bool) -> String {
        let formatted = currencyFormatter.string(from: price as NSDecimalNumber) ?? ""
        return formatted
    }
}
```

### Step 2.5: Extract Interactor (Business Logic)

Move business logic from ViewController to Interactor:

```swift
// BEFORE (in ViewController)
// Business decisions mixed with UI

// AFTER (in Interactor)
final class ProductInteractor: ProductBusinessLogic, ProductDataStore {

    var presenter: ProductPresentationLogic?
    var worker: ProductWorkerLogic?
    var router: ProductRoutingLogic?

    // DataStore
    var product: ProductEntity?
    var productId: String?

    func fetchProduct(request: Product.FetchProduct.Request) {
        presenter?.presentLoading(isLoading: true)

        Task { @MainActor in
            defer { presenter?.presentLoading(isLoading: false) }

            do {
                let product = try await worker?.fetchProduct(id: request.productId)
                self.product = product
                let response = Product.FetchProduct.Response(result: .success(product!))
                presenter?.presentProduct(response: response)
            } catch {
                let response = Product.FetchProduct.Response(result: .failure(.fetchFailed))
                presenter?.presentProduct(response: response)
            }
        }
    }

    func addToCart(request: Product.AddToCart.Request) {
        guard let product = product else { return }

        Task { @MainActor in
            do {
                try await worker?.addToCart(productId: product.id, quantity: request.quantity)
                let response = Product.AddToCart.Response(result: .success(()))
                presenter?.presentAddToCartResult(response: response)
            } catch {
                let response = Product.AddToCart.Response(result: .failure(.addFailed))
                presenter?.presentAddToCartResult(response: response)
            }
        }
    }
}
```

### Step 2.6: Refactor ViewController (Display Only)

```swift
// AFTER - Clean ViewController
final class ProductViewController: UIViewController {

    // MARK: - VIP

    var interactor: ProductBusinessLogic?
    var router: ProductRoutingLogic?

    // MARK: - UI

    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let saleBadge = UILabel()
    private let buyButton = UIButton()
    private let loadingIndicator = UIActivityIndicatorView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchProduct()
    }

    // MARK: - Setup

    private func setupUI() {
        // Pure UI setup - no business logic
    }

    // MARK: - Actions

    private func fetchProduct() {
        guard let productId = router?.dataStore?.productId else { return }
        let request = Product.FetchProduct.Request(productId: productId)
        interactor?.fetchProduct(request: request)
    }

    @objc private func buyTapped() {
        let request = Product.AddToCart.Request(quantity: 1)
        interactor?.addToCart(request: request)
    }
}

// MARK: - DisplayLogic

extension ProductViewController: ProductDisplayLogic {

    func displayProduct(viewModel: Product.FetchProduct.ViewModel) {
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.formattedPrice
        saleBadge.isHidden = !viewModel.showSaleBadge
        saleBadge.text = viewModel.saleBadgeText
    }

    func displayAddToCartResult(viewModel: Product.AddToCart.ViewModel) {
        if viewModel.isSuccess {
            showToast(viewModel.message)
        } else {
            showError(viewModel.message)
        }
    }

    func displayLoading(isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    func displayError(message: String) {
        showAlert(title: "Error", message: message)
    }
}
```

## Phase 3: Wire Everything

### Step 3.1: Create Configurator

```swift
enum ProductConfigurator {

    static func configure(productId: String) -> ProductViewController {
        let viewController = ProductViewController()
        let interactor = ProductInteractor()
        let presenter = ProductPresenter()
        let worker = ProductWorker()
        let router = ProductRouter()

        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = worker
        interactor.router = router
        interactor.productId = productId
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor

        return viewController
    }
}
```

### Step 3.2: Update Navigation

```swift
// BEFORE (legacy)
let vc = ProductViewController()
vc.productId = "123"
navigationController?.pushViewController(vc, animated: true)

// AFTER (VIP+W)
let vc = ProductConfigurator.configure(productId: "123")
navigationController?.pushViewController(vc, animated: true)
```

## Phase 4: Verify & Clean Up

### Step 4.1: Run Tests

```swift
// New VIP+W tests
final class ProductInteractorTests: XCTestCase {

    func test_fetchProduct_success_presentsProduct() async {
        // Given
        let mockPresenter = MockProductPresenter()
        let mockWorker = MockProductWorker()
        mockWorker.fetchProductResult = .success(ProductEntity.mock)

        let sut = ProductInteractor()
        sut.presenter = mockPresenter
        sut.worker = mockWorker

        // When
        sut.fetchProduct(request: .init(productId: "123"))
        await waitForAsync()

        // Then
        XCTAssertTrue(mockPresenter.presentProductCalled)
    }
}
```

### Step 4.2: Remove Legacy Code

```swift
// Delete old methods from ViewController
// - loadProduct()
// - All URLSession calls
// - All formatting logic
// - All business logic
```

### Step 4.3: Update Characterization Tests

Convert legacy tests to VIP+W tests:

```swift
// BEFORE: Testing ViewController directly
func test_legacy_loadProduct_displaysName() {
    let sut = ProductViewController()
    // ...
}

// AFTER: Testing each component
func test_presenter_formatsPriceCorrectly() {
    let sut = ProductPresenter()
    // ...
}

func test_interactor_fetchesFromWorker() {
    let sut = ProductInteractor()
    // ...
}
```

## Migration Checklist

### Per Screen Migration

- [ ] **Analysis**
  - [ ] Document current responsibilities
  - [ ] List all API calls
  - [ ] List all navigation paths
  - [ ] Identify state variables

- [ ] **Preparation**
  - [ ] Write characterization tests
  - [ ] Create VIP+W file structure
  - [ ] Define protocols

- [ ] **Extraction**
  - [ ] Extract Worker (API calls)
  - [ ] Extract Presenter (formatting)
  - [ ] Extract Interactor (business logic)
  - [ ] Extract Router (navigation)
  - [ ] Create Models (Request/Response/ViewModel)

- [ ] **Integration**
  - [ ] Create Configurator
  - [ ] Update ViewController to DisplayLogic only
  - [ ] Wire all components

- [ ] **Verification**
  - [ ] All tests pass
  - [ ] Manual testing
  - [ ] Remove dead code
  - [ ] Code review

## Common Migration Patterns

### Singleton → Injected Dependency

```swift
// BEFORE
class ViewController {
    func save() {
        UserDefaults.standard.set(value, forKey: "key")
    }
}

// AFTER
protocol StorageProtocol {
    func save(_ value: Any, forKey: String)
}

class Worker {
    private let storage: StorageProtocol

    init(storage: StorageProtocol = UserDefaultsStorage()) {
        self.storage = storage
    }
}
```

### Callback Hell → Async/Await

```swift
// BEFORE
func loadData() {
    api.fetchUser { user in
        api.fetchOrders(userId: user.id) { orders in
            api.fetchProducts(orderIds: orders.map { $0.id }) { products in
                self.display(user, orders, products)
            }
        }
    }
}

// AFTER
func loadData() async throws {
    let user = try await worker.fetchUser()
    let orders = try await worker.fetchOrders(userId: user.id)
    let products = try await worker.fetchProducts(orderIds: orders.map { $0.id })
    return (user, orders, products)
}
```

### Massive Switch → Strategy Pattern

```swift
// BEFORE
func handleAction(_ action: String) {
    switch action {
    case "buy": // 50 lines
    case "save": // 50 lines
    case "share": // 50 lines
    // ...
    }
}

// AFTER
protocol ActionHandler {
    func handle()
}

class BuyHandler: ActionHandler { ... }
class SaveHandler: ActionHandler { ... }
class ShareHandler: ActionHandler { ... }
```

## Tips for Success

1. **Start small** - Pick the simplest screen first
2. **Pair program** - Migration is easier with a partner
3. **Time-box** - Set limits to avoid endless refactoring
4. **Document decisions** - Future you will thank you
5. **Celebrate wins** - Each migrated screen is progress!

## Pre-Migration Interview

Before starting any migration, gather requirements using `AskUserQuestion`:

### Migration Questions

**Question 1: Migration Goal**
- Header: "Goal"
- Question: "What is your migration goal?"
- Options:
  - Full VIP+W migration - Complete architecture transformation
  - Partial cleanup - Extract some components, keep others
  - Just analyze - Understand the mess before deciding
  - Incremental improvement - Small steps over time

**Question 2: Current State**
- Header: "Current"
- Question: "What's the current code architecture?"
- Options:
  - Massive ViewController - Everything in one file
  - MVC with fat models - Logic spread across M and C
  - Mixed patterns - Some clean, some messy
  - Unknown - Need to analyze first

**Question 3: Test Coverage**
- Header: "Tests"
- Question: "What's the current test situation?"
- Options:
  - Good test coverage - Can refactor confidently
  - Some tests exist - Partial safety net
  - No tests - Need to add tests first
  - Don't know - Need to check

**Question 4: Risk Tolerance**
- Header: "Risk"
- Question: "How much risk can you accept?"
- Options:
  - Low risk (Recommended) - Small, verified changes
  - Medium risk - Larger changes with testing
  - High risk - Aggressive refactoring, tight timeline

### Interview Flow

1. Ask questions using AskUserQuestion
2. Summarize: "Planning [goal] migration from [current state] with [tests] and [risk] tolerance"
3. Analyze current code
4. Present migration plan
5. Get approval before making changes

### Skip Interview If:
- User provided detailed migration requirements
- User says "skip questions" or "just do it"
- User just wants specific refactoring guidance
