import XCTest
@testable import ClaudeUsageWidget

final class SnapshotCacheTests: XCTestCase {
    private func tempURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("cache-\(UUID().uuidString).json")
    }

    private let sample = UsageSnapshot(
        session: UsageWindow(percent: 30, resetsAt: nil),
        weekly: UsageWindow(percent: 60, resetsAt: nil),
        modelWeeklies: [],
        fetchedAt: Date(timeIntervalSince1970: 555)
    )

    func testLoadReturnsNilWhenAbsent() {
        let cache = SnapshotCache(fileURL: tempURL())
        XCTAssertNil(cache.load())
    }

    func testSaveThenLoadRoundTrips() {
        let url = tempURL()
        defer { try? FileManager.default.removeItem(at: url) }
        let cache = SnapshotCache(fileURL: url)
        cache.save(sample)
        XCTAssertEqual(cache.load(), sample)
    }

    func testLoadReturnsNilForCorruptFile() throws {
        let url = tempURL()
        defer { try? FileManager.default.removeItem(at: url) }
        try Data("corrupt".utf8).write(to: url)
        XCTAssertNil(SnapshotCache(fileURL: url).load())
    }
}
