---
name: VIP+W Architecture
description: VIP+W (View-Interactor-Presenter-Worker) Clean Architecture for iOS with unidirectional data flow and proper separation of concerns
version: 1.0.0
---

# VIP+W Clean Architecture

A scalable, testable architecture pattern for iOS apps with strict separation of concerns and unidirectional data flow.

## Components Overview

### View (ViewController)
- **Responsibility**: Display logic ONLY
- **Protocol**: `DisplayLogic`
- **Does**: Renders UI, forwards user actions to Interactor
- **Does NOT**: Contain business logic, format data, make API calls

### Interactor
- **Responsibility**: Orchestrates business logic
- **Protocol**: `BusinessLogic`
- **Does**: Receives requests from View, coordinates Workers, sends responses to Presenter
- **Does NOT**: Format data for display, handle UI, make direct API calls

### Presenter
- **Responsibility**: Formats data for display
- **Protocol**: `PresentationLogic`
- **Does**: Transforms business data into ViewModels, calls View methods
- **Does NOT**: Contain business logic, hold state, access network

### Worker
- **Responsibility**: Handles async operations
- **Protocol**: `WorkerLogic`
- **Does**: API calls, database operations, heavy computations
- **Does NOT**: Know about View or Presenter, contain business decisions

### Router/Wireframe
- **Responsibility**: Navigation between scenes
- **Protocol**: `RoutingLogic`, `DataPassingProtocol`
- **Does**: Push/present view controllers, pass data between scenes
- **Does NOT**: Contain business logic

### Models
- **Request**: Data sent from View to Interactor
- **Response**: Data sent from Interactor to Presenter
- **ViewModel**: Data sent from Presenter to View

## Data Flow (Unidirectional)

```
┌───────────────────────────────────────────────────────────────┐
│                                                               │
│   View ──request──► Interactor ──delegate──► Worker          │
│     ▲                    │                      │             │
│     │                    │◄─────result──────────┘             │
│     │                    │                                    │
│     │                    ▼                                    │
│     └──viewModel──── Presenter                                │
│                                                               │
│   Router: Navigation between scenes (accessed via Interactor) │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

## File Structure Template

```
SceneName/
├── SceneNameViewController.swift    # View (DisplayLogic)
├── SceneNameInteractor.swift        # Business Logic (BusinessLogic)
├── SceneNamePresenter.swift         # Format for Display (PresentationLogic)
├── SceneNameWorker.swift            # Async Operations (WorkerLogic)
├── SceneNameRouter.swift            # Navigation (RoutingLogic)
├── SceneNameModels.swift            # Request/Response/ViewModel
└── SceneNameConfigurator.swift      # DI Assembly
```

## Protocol Definitions

### DisplayLogic (View conforms)

```swift
protocol LoginDisplayLogic: AnyObject {
    func displayLoginResult(viewModel: Login.Authenticate.ViewModel)
    func displayValidationError(viewModel: Login.Validate.ViewModel)
    func displayLoading(isLoading: Bool)
}
```

### BusinessLogic (Interactor conforms)

```swift
protocol LoginBusinessLogic {
    func authenticate(request: Login.Authenticate.Request)
    func validateInput(request: Login.Validate.Request)
}
```

### PresentationLogic (Presenter conforms)

```swift
protocol LoginPresentationLogic {
    func presentLoginResult(response: Login.Authenticate.Response)
    func presentValidationError(response: Login.Validate.Response)
    func presentLoading(isLoading: Bool)
}
```

### WorkerLogic (Worker conforms)

```swift
protocol LoginWorkerLogic {
    func login(email: String, password: String) async throws -> User
    func validateCredentials(email: String, password: String) -> ValidationResult
}
```

### RoutingLogic (Router conforms)

```swift
protocol LoginRoutingLogic {
    func routeToHome()
    func routeToForgotPassword()
    func routeToSignup()
}

protocol LoginDataPassing {
    var dataStore: LoginDataStore? { get }
}
```

### DataStore (Shared state between scenes)

```swift
protocol LoginDataStore {
    var authenticatedUser: User? { get set }
}
```

## Complete Code Templates

### Models (SceneNameModels.swift)

```swift
import Foundation

enum Login {

    // MARK: - Use Cases

    enum Authenticate {
        struct Request {
            let email: String
            let password: String
        }

        struct Response {
            let result: Result<User, AuthError>
        }

        struct ViewModel {
            let isSuccess: Bool
            let errorMessage: String?
            let welcomeMessage: String?
        }
    }

    enum Validate {
        struct Request {
            let email: String
            let password: String
        }

        struct Response {
            let emailError: String?
            let passwordError: String?
        }

        struct ViewModel {
            let emailErrorText: String?
            let passwordErrorText: String?
            let isValid: Bool
        }
    }
}
```

### Worker (SceneNameWorker.swift)

```swift
import Foundation

protocol LoginWorkerLogic {
    func login(email: String, password: String) async throws -> User
    func validateCredentials(email: String, password: String) -> ValidationResult
}

final class LoginWorker: LoginWorkerLogic {

    // MARK: - Dependencies

    private let apiClient: APIClientProtocol
    private let validator: CredentialValidatorProtocol

    // MARK: - Init

    init(
        apiClient: APIClientProtocol = APIClient.shared,
        validator: CredentialValidatorProtocol = CredentialValidator()
    ) {
        self.apiClient = apiClient
        self.validator = validator
    }

    // MARK: - WorkerLogic

    func login(email: String, password: String) async throws -> User {
        let request = LoginRequest(email: email, password: password)
        let response: LoginResponse = try await apiClient.perform(request)
        return response.user
    }

    func validateCredentials(email: String, password: String) -> ValidationResult {
        validator.validate(email: email, password: password)
    }
}

struct ValidationResult {
    let emailError: String?
    let passwordError: String?

    var isValid: Bool {
        emailError == nil && passwordError == nil
    }
}
```

### Interactor (SceneNameInteractor.swift)

```swift
import Foundation

protocol LoginBusinessLogic {
    func authenticate(request: Login.Authenticate.Request)
    func validateInput(request: Login.Validate.Request)
}

protocol LoginDataStore {
    var authenticatedUser: User? { get set }
}

final class LoginInteractor: LoginBusinessLogic, LoginDataStore {

    // MARK: - Dependencies

    var presenter: LoginPresentationLogic?
    var worker: LoginWorkerLogic

    // MARK: - DataStore

    var authenticatedUser: User?

    // MARK: - Init

    init(worker: LoginWorkerLogic = LoginWorker()) {
        self.worker = worker
    }

    // MARK: - BusinessLogic

    func authenticate(request: Login.Authenticate.Request) {
        presenter?.presentLoading(isLoading: true)

        Task { @MainActor in
            defer { presenter?.presentLoading(isLoading: false) }

            do {
                let user = try await worker.login(
                    email: request.email,
                    password: request.password
                )
                authenticatedUser = user
                let response = Login.Authenticate.Response(result: .success(user))
                presenter?.presentLoginResult(response: response)
            } catch let error as AuthError {
                let response = Login.Authenticate.Response(result: .failure(error))
                presenter?.presentLoginResult(response: response)
            } catch {
                let response = Login.Authenticate.Response(result: .failure(.unknown))
                presenter?.presentLoginResult(response: response)
            }
        }
    }

    func validateInput(request: Login.Validate.Request) {
        let result = worker.validateCredentials(
            email: request.email,
            password: request.password
        )
        let response = Login.Validate.Response(
            emailError: result.emailError,
            passwordError: result.passwordError
        )
        presenter?.presentValidationError(response: response)
    }
}
```

### Presenter (SceneNamePresenter.swift)

```swift
import Foundation

protocol LoginPresentationLogic {
    func presentLoginResult(response: Login.Authenticate.Response)
    func presentValidationError(response: Login.Validate.Response)
    func presentLoading(isLoading: Bool)
}

final class LoginPresenter: LoginPresentationLogic {

    // MARK: - Dependencies

    weak var viewController: LoginDisplayLogic?

    // MARK: - PresentationLogic

    func presentLoginResult(response: Login.Authenticate.Response) {
        let viewModel: Login.Authenticate.ViewModel

        switch response.result {
        case .success(let user):
            viewModel = Login.Authenticate.ViewModel(
                isSuccess: true,
                errorMessage: nil,
                welcomeMessage: "Welcome, \(user.name)!"
            )

        case .failure(let error):
            viewModel = Login.Authenticate.ViewModel(
                isSuccess: false,
                errorMessage: error.localizedDescription,
                welcomeMessage: nil
            )
        }

        viewController?.displayLoginResult(viewModel: viewModel)
    }

    func presentValidationError(response: Login.Validate.Response) {
        let viewModel = Login.Validate.ViewModel(
            emailErrorText: response.emailError,
            passwordErrorText: response.passwordError,
            isValid: response.emailError == nil && response.passwordError == nil
        )
        viewController?.displayValidationError(viewModel: viewModel)
    }

    func presentLoading(isLoading: Bool) {
        viewController?.displayLoading(isLoading: isLoading)
    }
}
```

### ViewController (SceneNameViewController.swift)

```swift
import UIKit

protocol LoginDisplayLogic: AnyObject {
    func displayLoginResult(viewModel: Login.Authenticate.ViewModel)
    func displayValidationError(viewModel: Login.Validate.ViewModel)
    func displayLoading(isLoading: Bool)
}

final class LoginViewController: UIViewController {

    // MARK: - VIP References

    var interactor: LoginBusinessLogic?
    var router: (LoginRoutingLogic & LoginDataPassing)?

    // MARK: - UI Elements

    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emailErrorLabel = UILabel()
    private let passwordErrorLabel = UILabel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        // Layout code here (see uikit-layouting skill)
    }

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    // MARK: - Actions

    @objc private func loginTapped() {
        let request = Login.Authenticate.Request(
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
        interactor?.authenticate(request: request)
    }

    @objc private func textFieldDidChange() {
        let request = Login.Validate.Request(
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
        interactor?.validateInput(request: request)
    }
}

// MARK: - DisplayLogic

extension LoginViewController: LoginDisplayLogic {

    func displayLoginResult(viewModel: Login.Authenticate.ViewModel) {
        if viewModel.isSuccess {
            router?.routeToHome()
        } else if let errorMessage = viewModel.errorMessage {
            showAlert(title: "Error", message: errorMessage)
        }
    }

    func displayValidationError(viewModel: Login.Validate.ViewModel) {
        emailErrorLabel.text = viewModel.emailErrorText
        passwordErrorLabel.text = viewModel.passwordErrorText
        loginButton.isEnabled = viewModel.isValid
    }

    func displayLoading(isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
```

### Router (SceneNameRouter.swift)

```swift
import UIKit

protocol LoginRoutingLogic {
    func routeToHome()
    func routeToForgotPassword()
    func routeToSignup()
}

protocol LoginDataPassing {
    var dataStore: LoginDataStore? { get }
}

final class LoginRouter: LoginRoutingLogic, LoginDataPassing {

    // MARK: - Dependencies

    weak var viewController: LoginViewController?
    var dataStore: LoginDataStore?

    // MARK: - Routing

    func routeToHome() {
        let destinationVC = HomeConfigurator.configure()
        passDataToHome(destination: destinationVC)
        navigateToHome(destination: destinationVC)
    }

    func routeToForgotPassword() {
        let destinationVC = ForgotPasswordConfigurator.configure()
        viewController?.navigationController?.pushViewController(destinationVC, animated: true)
    }

    func routeToSignup() {
        let destinationVC = SignupConfigurator.configure()
        viewController?.navigationController?.pushViewController(destinationVC, animated: true)
    }

    // MARK: - Navigation

    private func navigateToHome(destination: HomeViewController) {
        viewController?.navigationController?.setViewControllers([destination], animated: true)
    }

    // MARK: - Data Passing

    private func passDataToHome(destination: HomeViewController) {
        guard let user = dataStore?.authenticatedUser else { return }
        destination.router?.dataStore?.currentUser = user
    }
}
```

### Configurator (SceneNameConfigurator.swift)

```swift
import UIKit

enum LoginConfigurator {

    static func configure() -> LoginViewController {
        let viewController = LoginViewController()
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter()
        let worker = LoginWorker()

        // Connect VIP cycle
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = worker
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor

        return viewController
    }
}
```

## Worker Responsibilities

### API Calls
```swift
func fetchUser(id: String) async throws -> User {
    try await apiClient.get("/users/\(id)")
}
```

### Database Operations
```swift
func saveUser(_ user: User) async throws {
    try await coreDataManager.save(user)
}
```

### File I/O
```swift
func loadCachedData() async throws -> Data {
    try await fileManager.read(from: cacheURL)
}
```

### Heavy Computations
```swift
func processImage(_ image: UIImage) async -> UIImage {
    await Task.detached(priority: .userInitiated) {
        image.applyFilters()
    }.value
}
```

## Testing Strategy

### Test Interactor with Mock Worker
```swift
final class LoginInteractorTests: XCTestCase {
    var sut: LoginInteractor!
    var mockPresenter: MockLoginPresenter!
    var mockWorker: MockLoginWorker!

    override func setUp() {
        mockPresenter = MockLoginPresenter()
        mockWorker = MockLoginWorker()
        sut = LoginInteractor(worker: mockWorker)
        sut.presenter = mockPresenter
    }

    func testAuthenticateSuccess() async {
        mockWorker.loginResult = .success(User.mock)

        sut.authenticate(request: .init(email: "test@test.com", password: "password"))

        await fulfillment(of: [mockPresenter.presentLoginResultCalled])
        XCTAssertTrue(mockPresenter.lastLoginResponse?.result.isSuccess == true)
    }
}
```

### Test Presenter with Mock View
```swift
final class LoginPresenterTests: XCTestCase {
    var sut: LoginPresenter!
    var mockView: MockLoginViewController!

    override func setUp() {
        mockView = MockLoginViewController()
        sut = LoginPresenter()
        sut.viewController = mockView
    }

    func testPresentLoginResultSuccess() {
        let response = Login.Authenticate.Response(result: .success(User.mock))

        sut.presentLoginResult(response: response)

        XCTAssertTrue(mockView.lastLoginViewModel?.isSuccess == true)
        XCTAssertNotNil(mockView.lastLoginViewModel?.welcomeMessage)
    }
}
```

## Best Practices

1. **Never skip the Worker** - All async operations go through Worker
2. **Keep Presenter pure** - No side effects, only data transformation
3. **View is dumb** - Only calls `interactor?.someMethod(request:)`
4. **Use the Configurator** - Single place for dependency assembly
5. **Protocol-first** - Define protocols before implementations
6. **Test each layer** - Mock dependencies for isolation

## Pre-Creation Interview

Before creating a new VIP+W scene, gather requirements using `AskUserQuestion`:

### Scene Creation Questions

**Question 1: Scene Purpose**
- Header: "Purpose"
- Question: "What is the main purpose of this scene?"
- Options:
  - Display data - Show information (list, detail, profile)
  - Form input - Collect user input (login, registration, settings)
  - Navigation hub - Route to other scenes (home, dashboard)
  - Action flow - Multi-step process (checkout, onboarding)

**Question 2: Data Requirements**
- Header: "Data"
- Question: "What data operations does this scene need?"
- Options:
  - Fetch from API - Load data from backend
  - Local storage - Read/write to database
  - User input only - No external data
  - Multiple sources - API + local + input

**Question 3: Navigation Pattern**
- Header: "Navigation"
- Question: "How does this scene connect to others?"
- Options:
  - Push detail - Navigate deeper (list → detail)
  - Modal presentation - Overlay screens
  - Replace root - New flow (login → home)
  - Tab child - Part of tab navigation

### Interview Flow

1. Ask questions using AskUserQuestion
2. Summarize: "Creating a [purpose] scene with [data] operations using [navigation] pattern"
3. Generate file structure
4. Create protocols first
5. Implement each component

### Skip Interview If:
- User provided detailed scene requirements
- User says "skip questions" or "just do it"
- Scene purpose is obvious from context
