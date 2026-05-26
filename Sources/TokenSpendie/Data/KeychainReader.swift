import Foundation
import Security

/// Reads the Claude Code OAuth credentials from the login Keychain.
///
/// Claude Code may store credentials under a suffixed service name
/// (e.g. "Claude Code-credentials-d06a1752"). This reader discovers
/// all matching entries and picks the one with the latest expiry.
struct KeychainReader: CredentialStore {
    let servicePrefix: String

    init(service: String = "Claude Code-credentials") {
        self.servicePrefix = service
    }

    func loadCredentials() throws -> OAuthCredentials {
        let services = discoverServices()
        guard !services.isEmpty else { throw CredentialError.notFound }

        var best: OAuthCredentials?
        var bestExpiry: Date = .distantPast
        var lastError: Error = CredentialError.notFound

        for svc in services {
            do {
                let creds = try loadFromService(svc)
                let expiry = creds.expiresAt ?? .distantPast
                if best == nil || expiry > bestExpiry {
                    best = creds
                    bestExpiry = expiry
                }
            } catch {
                lastError = error
            }
        }

        guard let result = best else { throw lastError }
        return result
    }

    func credentialsExist() -> Bool {
        !discoverServices().isEmpty
    }

    // MARK: - Private

    private func loadFromService(_ service: String) throws -> OAuthCredentials {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else { throw CredentialError.malformed }
            return try OAuthCredentialsParser.parse(data)
        case errSecItemNotFound:
            throw CredentialError.notFound
        case errSecAuthFailed, errSecUserCanceled, errSecInteractionNotAllowed:
            throw CredentialError.accessDenied
        default:
            throw CredentialError.accessDenied
        }
    }

    /// Finds all Keychain service names matching `servicePrefix`.
    private func discoverServices() -> [String] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return []
        }
        return items.compactMap { item in
            guard let svc = item[kSecAttrService as String] as? String,
                  svc == servicePrefix || svc.hasPrefix(servicePrefix + "-") else {
                return nil
            }
            return svc
        }
    }
}
