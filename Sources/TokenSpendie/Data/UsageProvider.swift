import Foundation

/// Injected HTTP transport: performs a request and returns the body + HTTP response.
typealias HTTPTransport = (URLRequest) async throws -> (Data, HTTPURLResponse)

/// Default transport backed by `URLSession`.
enum DefaultTransport {
    static let shared: HTTPTransport = { request in
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw ProviderError.network }
            return (data, http)
        } catch let error as ProviderError {
            throw error
        } catch {
            throw ProviderError.network
        }
    }
}

/// Fetches a usage snapshot given a valid access token.
protocol UsageProvider {
    func fetchUsage(accessToken: String) async throws -> UsageSnapshot
}
