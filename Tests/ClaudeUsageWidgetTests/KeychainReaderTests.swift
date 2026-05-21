import XCTest
@testable import ClaudeUsageWidget

final class KeychainReaderTests: XCTestCase {
    func testMissingItemThrowsNotFound() {
        let reader = KeychainReader(service: "ClaudeUsageWidget-NoSuchItem-\(UUID().uuidString)")
        XCTAssertThrowsError(try reader.loadCredentials()) { error in
            XCTAssertEqual(error as? CredentialError, .notFound)
        }
    }
}
