---
name: iOS Testing
description: Unit testing, UI testing, TDD patterns, mocking, and test doubles for VIP+W architecture
version: 1.0.0
---

# iOS Testing

Comprehensive testing strategies for iOS applications using VIP+W architecture, including unit tests, UI tests, and TDD patterns.

## Testing VIP+W Architecture

### Test Structure for VIP+W

```
Tests/
├── Scenes/
│   └── Login/
│       ├── LoginInteractorTests.swift
│       ├── LoginPresenterTests.swift
│       ├── LoginWorkerTests.swift
│       ├── LoginViewControllerTests.swift
│       └── Mocks/
│           ├── MockLoginPresenter.swift
│           ├── MockLoginWorker.swift
│           └── MockLoginDisplayLogic.swift
├── Workers/
│   └── APIClientTests.swift
├── Helpers/
│   └── XCTestCase+Async.swift
└── Mocks/
    └── MockURLSession.swift
```

### Testing the Interactor

```swift
import XCTest
@testable import MyApp

final class LoginInteractorTests: XCTestCase {

    // MARK: - Subject Under Test

    var sut: LoginInteractor!
    var mockPresenter: MockLoginPresenter!
    var mockWorker: MockLoginWorker!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockPresenter = MockLoginPresenter()
        mockWorker = MockLoginWorker()
        sut = LoginInteractor(worker: mockWorker)
        sut.presenter = mockPresenter
    }

    override func tearDown() {
        sut = nil
        mockPresenter = nil
        mockWorker = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_authenticate_withValidCredentials_shouldPresentSuccess() async {
        // Given
        let request = Login.Authenticate.Request(
            email: "test@example.com",
            password: "password123"
        )
        mockWorker.loginResult = .success(User.mock)

        // When
        sut.authenticate(request: request)

        // Then
        await waitForAsync()
        XCTAssertTrue(mockPresenter.presentLoginResultCalled)
        XCTAssertNotNil(mockPresenter.lastLoginResponse)

        if case .success(let user) = mockPresenter.lastLoginResponse?.result {
            XCTAssertEqual(user.email, "test@example.com")
        } else {
            XCTFail("Expected success result")
        }
    }

    func test_authenticate_withInvalidCredentials_shouldPresentError() async {
        // Given
        let request = Login.Authenticate.Request(
            email: "test@example.com",
            password: "wrong"
        )
        mockWorker.loginResult = .failure(.invalidCredentials)

        // When
        sut.authenticate(request: request)

        // Then
        await waitForAsync()
        XCTAssertTrue(mockPresenter.presentLoginResultCalled)

        if case .failure(let error) = mockPresenter.lastLoginResponse?.result {
            XCTAssertEqual(error, .invalidCredentials)
        } else {
            XCTFail("Expected failure result")
        }
    }

    func test_authenticate_shouldShowLoadingState() async {
        // Given
        let request = Login.Authenticate.Request(
            email: "test@example.com",
            password: "password123"
        )
        mockWorker.loginResult = .success(User.mock)

        // When
        sut.authenticate(request: request)

        // Then
        XCTAssertTrue(mockPresenter.presentLoadingCalled)
        XCTAssertTrue(mockPresenter.lastLoadingState == true)

        await waitForAsync()
        XCTAssertTrue(mockPresenter.lastLoadingState == false)
    }
}
```

### Testing the Presenter

```swift
import XCTest
@testable import MyApp

final class LoginPresenterTests: XCTestCase {

    // MARK: - Subject Under Test

    var sut: LoginPresenter!
    var mockViewController: MockLoginViewController!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockViewController = MockLoginViewController()
        sut = LoginPresenter()
        sut.viewController = mockViewController
    }

    override func tearDown() {
        sut = nil
        mockViewController = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_presentLoginResult_withSuccess_shouldDisplayWelcomeMessage() {
        // Given
        let user = User(id: "1", name: "John", email: "john@test.com")
        let response = Login.Authenticate.Response(result: .success(user))

        // When
        sut.presentLoginResult(response: response)

        // Then
        XCTAssertTrue(mockViewController.displayLoginResultCalled)
        XCTAssertTrue(mockViewController.lastLoginViewModel?.isSuccess == true)
        XCTAssertEqual(
            mockViewController.lastLoginViewModel?.welcomeMessage,
            "Welcome, John!"
        )
        XCTAssertNil(mockViewController.lastLoginViewModel?.errorMessage)
    }

    func test_presentLoginResult_withFailure_shouldDisplayErrorMessage() {
        // Given
        let response = Login.Authenticate.Response(
            result: .failure(.invalidCredentials)
        )

        // When
        sut.presentLoginResult(response: response)

        // Then
        XCTAssertTrue(mockViewController.displayLoginResultCalled)
        XCTAssertFalse(mockViewController.lastLoginViewModel?.isSuccess ?? true)
        XCTAssertNotNil(mockViewController.lastLoginViewModel?.errorMessage)
        XCTAssertNil(mockViewController.lastLoginViewModel?.welcomeMessage)
    }

    func test_presentValidationError_withInvalidEmail_shouldShowEmailError() {
        // Given
        let response = Login.Validate.Response(
            emailError: "Invalid email format",
            passwordError: nil
        )

        // When
        sut.presentValidationError(response: response)

        // Then
        XCTAssertTrue(mockViewController.displayValidationErrorCalled)
        XCTAssertEqual(
            mockViewController.lastValidationViewModel?.emailErrorText,
            "Invalid email format"
        )
        XCTAssertNil(mockViewController.lastValidationViewModel?.passwordErrorText)
        XCTAssertFalse(mockViewController.lastValidationViewModel?.isValid ?? true)
    }
}
```

### Testing the Worker

```swift
import XCTest
@testable import MyApp

final class LoginWorkerTests: XCTestCase {

    // MARK: - Subject Under Test

    var sut: LoginWorker!
    var mockAPIClient: MockAPIClient!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        sut = LoginWorker(apiClient: mockAPIClient)
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_login_withValidCredentials_shouldReturnUser() async throws {
        // Given
        let expectedUser = User(id: "1", name: "John", email: "john@test.com")
        mockAPIClient.mockResponse = LoginResponse(user: expectedUser)

        // When
        let result = try await sut.login(email: "john@test.com", password: "password")

        // Then
        XCTAssertEqual(result.id, expectedUser.id)
        XCTAssertEqual(result.email, expectedUser.email)
    }

    func test_login_withNetworkError_shouldThrowError() async {
        // Given
        mockAPIClient.mockError = NetworkError.noConnection

        // When/Then
        do {
            _ = try await sut.login(email: "test@test.com", password: "password")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    func test_validateCredentials_withValidInput_shouldReturnValid() {
        // When
        let result = sut.validateCredentials(
            email: "valid@email.com",
            password: "validPassword123"
        )

        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.emailError)
        XCTAssertNil(result.passwordError)
    }

    func test_validateCredentials_withInvalidEmail_shouldReturnError() {
        // When
        let result = sut.validateCredentials(
            email: "invalid-email",
            password: "validPassword123"
        )

        // Then
        XCTAssertFalse(result.isValid)
        XCTAssertNotNil(result.emailError)
    }
}
```

## Mock Objects

### Mock Presenter

```swift
@testable import MyApp

final class MockLoginPresenter: LoginPresentationLogic {

    // MARK: - Call Tracking

    var presentLoginResultCalled = false
    var presentValidationErrorCalled = false
    var presentLoadingCalled = false

    var lastLoginResponse: Login.Authenticate.Response?
    var lastValidationResponse: Login.Validate.Response?
    var lastLoadingState: Bool?

    // MARK: - PresentationLogic

    func presentLoginResult(response: Login.Authenticate.Response) {
        presentLoginResultCalled = true
        lastLoginResponse = response
    }

    func presentValidationError(response: Login.Validate.Response) {
        presentValidationErrorCalled = true
        lastValidationResponse = response
    }

    func presentLoading(isLoading: Bool) {
        presentLoadingCalled = true
        lastLoadingState = isLoading
    }
}
```

### Mock Worker

```swift
@testable import MyApp

final class MockLoginWorker: LoginWorkerLogic {

    // MARK: - Stubbed Results

    var loginResult: Result<User, AuthError> = .failure(.unknown)
    var validationResult = ValidationResult(emailError: nil, passwordError: nil)

    // MARK: - Call Tracking

    var loginCalled = false
    var validateCalled = false

    var lastEmail: String?
    var lastPassword: String?

    // MARK: - WorkerLogic

    func login(email: String, password: String) async throws -> User {
        loginCalled = true
        lastEmail = email
        lastPassword = password

        switch loginResult {
        case .success(let user):
            return user
        case .failure(let error):
            throw error
        }
    }

    func validateCredentials(email: String, password: String) -> ValidationResult {
        validateCalled = true
        return validationResult
    }
}
```

### Mock ViewController

```swift
@testable import MyApp

final class MockLoginViewController: LoginDisplayLogic {

    // MARK: - Call Tracking

    var displayLoginResultCalled = false
    var displayValidationErrorCalled = false
    var displayLoadingCalled = false

    var lastLoginViewModel: Login.Authenticate.ViewModel?
    var lastValidationViewModel: Login.Validate.ViewModel?
    var lastLoadingState: Bool?

    // MARK: - DisplayLogic

    func displayLoginResult(viewModel: Login.Authenticate.ViewModel) {
        displayLoginResultCalled = true
        lastLoginViewModel = viewModel
    }

    func displayValidationError(viewModel: Login.Validate.ViewModel) {
        displayValidationErrorCalled = true
        lastValidationViewModel = viewModel
    }

    func displayLoading(isLoading: Bool) {
        displayLoadingCalled = true
        lastLoadingState = isLoading
    }
}
```

## Async Testing Helpers

```swift
import XCTest

extension XCTestCase {

    /// Wait for async operations to complete
    func waitForAsync(timeout: TimeInterval = 1.0) async {
        let expectation = expectation(description: "Async wait")

        Task {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 100_000_000))
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: timeout + 0.5)
    }

    /// Wait for a condition to become true
    func waitFor(
        _ condition: @escaping () -> Bool,
        timeout: TimeInterval = 2.0,
        message: String = "Condition not met"
    ) {
        let expectation = expectation(description: message)

        let timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if condition() {
                timer.invalidate()
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)
        timer.invalidate()
    }
}
```

## UI Testing

### Page Object Pattern

```swift
import XCTest

// MARK: - Base Page

protocol Page {
    var app: XCUIApplication { get }
}

extension Page {
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        element.waitForExistence(timeout: timeout)
    }
}

// MARK: - Login Page

final class LoginPage: Page {
    let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Elements

    var emailTextField: XCUIElement {
        app.textFields["emailTextField"]
    }

    var passwordTextField: XCUIElement {
        app.secureTextFields["passwordTextField"]
    }

    var loginButton: XCUIElement {
        app.buttons["loginButton"]
    }

    var errorLabel: XCUIElement {
        app.staticTexts["errorLabel"]
    }

    var loadingIndicator: XCUIElement {
        app.activityIndicators["loadingIndicator"]
    }

    // MARK: - Actions

    @discardableResult
    func enterEmail(_ email: String) -> Self {
        emailTextField.tap()
        emailTextField.typeText(email)
        return self
    }

    @discardableResult
    func enterPassword(_ password: String) -> Self {
        passwordTextField.tap()
        passwordTextField.typeText(password)
        return self
    }

    @discardableResult
    func tapLogin() -> Self {
        loginButton.tap()
        return self
    }

    func login(email: String, password: String) -> HomePage {
        enterEmail(email)
        enterPassword(password)
        tapLogin()
        return HomePage(app: app)
    }

    // MARK: - Assertions

    func verifyErrorDisplayed(_ message: String) -> Self {
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(errorLabel.label, message)
        return self
    }

    func verifyLoginButtonDisabled() -> Self {
        XCTAssertFalse(loginButton.isEnabled)
        return self
    }
}
```

### UI Test Example

```swift
import XCTest

final class LoginUITests: XCTestCase {

    var app: XCUIApplication!
    var loginPage: LoginPage!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        loginPage = LoginPage(app: app)
    }

    override func tearDown() {
        app = nil
        loginPage = nil
        super.tearDown()
    }

    func test_login_withValidCredentials_shouldNavigateToHome() {
        let homePage = loginPage.login(
            email: "test@example.com",
            password: "password123"
        )

        XCTAssertTrue(homePage.welcomeLabel.waitForExistence(timeout: 5))
    }

    func test_login_withInvalidCredentials_shouldShowError() {
        loginPage
            .enterEmail("test@example.com")
            .enterPassword("wrongpassword")
            .tapLogin()
            .verifyErrorDisplayed("Invalid credentials")
    }

    func test_login_withEmptyFields_shouldDisableButton() {
        loginPage.verifyLoginButtonDisabled()
    }
}
```

## Test-Driven Development (TDD)

### Red-Green-Refactor Cycle

```swift
// 1. RED - Write a failing test first
func test_validateEmail_withInvalidFormat_shouldReturnError() {
    let validator = EmailValidator()
    let result = validator.validate("invalid-email")
    XCTAssertFalse(result.isValid)
    XCTAssertEqual(result.error, "Invalid email format")
}

// 2. GREEN - Write minimal code to pass
struct EmailValidator {
    func validate(_ email: String) -> ValidationResult {
        let isValid = email.contains("@") && email.contains(".")
        return ValidationResult(
            isValid: isValid,
            error: isValid ? nil : "Invalid email format"
        )
    }
}

// 3. REFACTOR - Improve the code
struct EmailValidator {
    private let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    func validate(_ email: String) -> ValidationResult {
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isValid = predicate.evaluate(with: email)
        return ValidationResult(
            isValid: isValid,
            error: isValid ? nil : "Invalid email format"
        )
    }
}
```

## Testing Best Practices

### Naming Convention

```swift
// Pattern: test_[methodName]_[scenario]_[expectedBehavior]

func test_authenticate_withValidCredentials_shouldReturnUser() { }
func test_authenticate_withExpiredToken_shouldRefreshAndRetry() { }
func test_fetchUsers_withNetworkError_shouldReturnCachedData() { }
```

### Arrange-Act-Assert (AAA)

```swift
func test_calculateTotal_withDiscountCode_shouldApplyDiscount() {
    // Arrange (Given)
    let cart = ShoppingCart()
    cart.addItem(Item(price: 100))
    cart.applyDiscountCode("SAVE20")

    // Act (When)
    let total = cart.calculateTotal()

    // Assert (Then)
    XCTAssertEqual(total, 80)
}
```

### Test Data Builders

```swift
// MARK: - User Builder

extension User {
    static var mock: User {
        User(id: "mock-id", name: "Mock User", email: "mock@test.com")
    }

    static func mock(
        id: String = "mock-id",
        name: String = "Mock User",
        email: String = "mock@test.com"
    ) -> User {
        User(id: id, name: name, email: email)
    }
}

// Usage
let user = User.mock(name: "Custom Name")
```

## Test Coverage Checklist

### Interactor Tests
- [ ] Happy path for each use case
- [ ] Error handling
- [ ] Loading state management
- [ ] Data store updates
- [ ] Edge cases (empty data, nil values)

### Presenter Tests
- [ ] Formatting logic
- [ ] ViewModel construction
- [ ] Error message formatting
- [ ] Date/number formatting

### Worker Tests
- [ ] API success responses
- [ ] API error responses
- [ ] Network failures
- [ ] Validation logic
- [ ] Caching behavior

### ViewController Tests
- [ ] Initial state
- [ ] User interactions trigger correct interactor methods
- [ ] ViewModel updates UI correctly

### UI Tests
- [ ] Critical user flows
- [ ] Error states
- [ ] Loading states
- [ ] Accessibility
