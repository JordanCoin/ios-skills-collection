---
name: iOS Security
description: iOS security best practices including Keychain Services, biometrics, data protection, network security, and App Attest
version: 1.0.0
---

# iOS Security Skill

Comprehensive guide to iOS security covering secure storage, authentication, network security, and compliance with Apple's security requirements.

## Keychain Services

### Secure Credential Storage

```swift
import Security

enum KeychainError: Error {
    case duplicateItem
    case itemNotFound
    case unexpectedStatus(OSStatus)
}

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    func save(password: String, for account: String, service: String) throws {
        let passwordData = password.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            // Update existing item
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account,
                kSecAttrService as String: service
            ]
            let updates: [String: Any] = [
                kSecValueData as String: passwordData
            ]
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updates as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func retrievePassword(for account: String, service: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = result as? Data,
              let password = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedStatus(errSecDecode)
        }

        return password
    }

    func delete(account: String, service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
```

### Keychain Access Levels

| Attribute | Description |
|-----------|-------------|
| `kSecAttrAccessibleWhenUnlocked` | Accessible when device unlocked |
| `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` | Same, but not backed up |
| `kSecAttrAccessibleAfterFirstUnlock` | Accessible after first unlock |
| `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` | Same, but not backed up |
| `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` | Requires passcode, not backed up |

## Biometric Authentication

### Face ID / Touch ID

```swift
import LocalAuthentication

final class BiometricAuthManager {
    enum BiometricType {
        case none
        case touchID
        case faceID
        case opticID  // Vision Pro
    }

    var biometricType: BiometricType {
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return .none
        }

        switch context.biometryType {
        case .touchID: return .touchID
        case .faceID: return .faceID
        case .opticID: return .opticID
        case .none: return .none
        @unknown default: return .none
        }
    }

    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error {
                throw error
            }
            return false
        }

        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }

    func authenticateWithFallback(reason: String) async throws -> Bool {
        let context = LAContext()

        // Use deviceOwnerAuthentication to allow passcode fallback
        return try await context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: reason
        )
    }
}
```

### Keychain with Biometric Protection

```swift
func saveBiometricProtectedItem(data: Data, account: String) throws {
    let access = SecAccessControlCreateWithFlags(
        nil,
        kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
        .biometryCurrentSet,  // Invalidates if biometrics change
        nil
    )!

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecValueData as String: data,
        kSecAttrAccessControl as String: access,
        kSecUseAuthenticationContext as String: LAContext()
    ]

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw KeychainError.unexpectedStatus(status)
    }
}
```

## Data Protection

### File Protection

```swift
// Set protection level when writing files
func writeSecureFile(data: Data, to url: URL) throws {
    try data.write(to: url, options: .completeFileProtection)
}

// Set protection on existing file
func setProtection(for url: URL) throws {
    try FileManager.default.setAttributes(
        [.protectionKey: FileProtectionType.complete],
        ofItemAtPath: url.path
    )
}
```

### Protection Levels

| Level | Description |
|-------|-------------|
| `.complete` | Only accessible when device unlocked |
| `.completeUnlessOpen` | Accessible if file was open when locked |
| `.completeUntilFirstUserAuthentication` | Accessible after first unlock |
| `.none` | No protection (avoid for sensitive data) |

## Cryptography

### CryptoKit (Preferred)

```swift
import CryptoKit

// Symmetric Encryption (AES-GCM)
func encrypt(data: Data, using key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.seal(data, using: key)
    return sealedBox.combined!
}

func decrypt(data: Data, using key: SymmetricKey) throws -> Data {
    let sealedBox = try AES.GCM.SealedBox(combined: data)
    return try AES.GCM.open(sealedBox, using: key)
}

// Key Derivation
func deriveKey(from password: String, salt: Data) -> SymmetricKey {
    let passwordData = Data(password.utf8)
    let key = HKDF<SHA256>.deriveKey(
        inputKeyMaterial: SymmetricKey(data: passwordData),
        salt: salt,
        info: Data("encryption".utf8),
        outputByteCount: 32
    )
    return key
}

// Hashing
func hash(data: Data) -> String {
    let digest = SHA256.hash(data: data)
    return digest.map { String(format: "%02x", $0) }.joined()
}

// HMAC
func authenticate(data: Data, key: SymmetricKey) -> Data {
    let authCode = HMAC<SHA256>.authenticationCode(for: data, using: key)
    return Data(authCode)
}
```

## Network Security

### App Transport Security (ATS)

```xml
<!-- Info.plist - Secure Configuration -->
<key>NSAppTransportSecurity</key>
<dict>
    <!-- ATS enabled by default, don't add anything for HTTPS-only -->
</dict>

<!-- If you MUST allow exceptions (document why!) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>legacy-api.example.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

### Certificate Pinning

```swift
import CryptoKit

final class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificateHashes: Set<String>

    init(pinnedHashes: [String]) {
        self.pinnedCertificateHashes = Set(pinnedHashes)
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Get server certificate
        guard let certificate = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let serverCert = certificate.first else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Hash the public key
        let serverCertData = SecCertificateCopyData(serverCert) as Data
        let hash = SHA256.hash(data: serverCertData)
        let hashString = hash.map { String(format: "%02x", $0) }.joined()

        if pinnedCertificateHashes.contains(hashString) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
```

## App Attest (iOS 14+)

### Device Integrity Verification

```swift
import DeviceCheck

final class AppAttestManager {
    private let service = DCAppAttestService.shared

    var isSupported: Bool {
        service.isSupported
    }

    func generateKey() async throws -> String {
        try await service.generateKey()
    }

    func attestKey(_ keyId: String, clientDataHash: Data) async throws -> Data {
        try await service.attestKey(keyId, clientDataHash: clientDataHash)
    }

    func generateAssertion(_ keyId: String, clientDataHash: Data) async throws -> Data {
        try await service.generateAssertion(keyId, clientDataHash: clientDataHash)
    }
}

// Usage in authentication flow
final class SecureAuthService {
    private let attestManager = AppAttestManager()
    private var keyId: String?

    func setupAttestation() async throws {
        guard attestManager.isSupported else {
            throw SecurityError.attestationNotSupported
        }

        keyId = try await attestManager.generateKey()

        // Get challenge from server
        let challenge = try await fetchChallenge()
        let clientDataHash = SHA256.hash(data: challenge)

        // Attest the key
        let attestation = try await attestManager.attestKey(
            keyId!,
            clientDataHash: Data(clientDataHash)
        )

        // Send attestation to server for verification
        try await verifyAttestation(attestation)
    }
}
```

## Secure Coding Practices

### Input Validation

```swift
// Validate and sanitize all external input
struct InputValidator {
    static func validateEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    static func sanitizeForDisplay(_ input: String) -> String {
        // Prevent potential XSS in WebViews
        input
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
```

### Secure Memory

```swift
// Clear sensitive data when done
extension Data {
    mutating func secureZero() {
        guard count > 0 else { return }
        withUnsafeMutableBytes { ptr in
            memset_s(ptr.baseAddress, ptr.count, 0, ptr.count)
        }
    }
}

// Use for temporary sensitive data
class SecureString {
    private var data: Data

    init(_ string: String) {
        data = Data(string.utf8)
    }

    var value: String {
        String(data: data, encoding: .utf8) ?? ""
    }

    deinit {
        data.secureZero()
    }
}
```

## References

- See `references/owasp-mobile-top10.md` for OWASP Mobile security guidelines
- See `references/privacy-manifest.md` for privacy manifest requirements
