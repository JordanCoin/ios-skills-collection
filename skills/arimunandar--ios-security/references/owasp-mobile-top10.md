# OWASP Mobile Top 10 (2024)

## M1: Improper Credential Usage

**Risk**: Hardcoded credentials, insecure storage

**Mitigations**:
- Never hardcode API keys or credentials
- Use Keychain for credential storage
- Implement proper session management
- Use OAuth 2.0 / OpenID Connect

```swift
// BAD
let apiKey = "sk_live_abc123..."

// GOOD
let apiKey = try KeychainManager.shared.retrievePassword(for: "api_key", service: "MyApp")
```

## M2: Inadequate Supply Chain Security

**Risk**: Compromised dependencies, malicious SDKs

**Mitigations**:
- Pin dependency versions
- Verify package integrity (checksums)
- Audit third-party SDKs
- Use Swift Package Manager with version locking

```swift
// Package.swift - Pin exact versions
.package(url: "https://github.com/example/package.git", exact: "1.2.3")
```

## M3: Insecure Authentication/Authorization

**Risk**: Weak authentication, improper session handling

**Mitigations**:
- Implement biometric authentication
- Use secure token storage
- Implement proper session timeout
- Verify authorization on server-side

## M4: Insufficient Input/Output Validation

**Risk**: Injection attacks, data corruption

**Mitigations**:
- Validate all input (client and server)
- Sanitize data before display
- Use parameterized queries
- Encode output properly

```swift
// Validate before use
guard InputValidator.validateEmail(email) else {
    throw ValidationError.invalidEmail
}
```

## M5: Insecure Communication

**Risk**: Man-in-the-middle, data interception

**Mitigations**:
- Use HTTPS exclusively
- Implement certificate pinning
- Don't disable ATS
- Verify TLS configuration

## M6: Inadequate Privacy Controls

**Risk**: Privacy violations, regulatory non-compliance

**Mitigations**:
- Implement privacy manifest
- Minimize data collection
- Provide data deletion
- Get proper consent

## M7: Insufficient Binary Protections

**Risk**: Reverse engineering, tampering

**Mitigations**:
- Enable code signing
- Use App Attest
- Implement jailbreak detection
- Obfuscate sensitive logic

## M8: Security Misconfiguration

**Risk**: Debug features in production, weak settings

**Mitigations**:
- Disable debug logging in production
- Review Info.plist settings
- Enable all security features
- Regular security audits

```swift
#if DEBUG
    logger.log(level: .debug, "Sensitive: \(data)")
#endif
```

## M9: Insecure Data Storage

**Risk**: Data leakage, unauthorized access

**Mitigations**:
- Use Keychain for credentials
- Enable file protection
- Encrypt sensitive data at rest
- Clear clipboard for sensitive data

## M10: Insufficient Cryptography

**Risk**: Weak encryption, key exposure

**Mitigations**:
- Use CryptoKit (AES-GCM, SHA-256)
- Never use MD5/SHA1 for security
- Use secure key derivation
- Protect encryption keys properly
