import XCTest
@testable import ClaudeUsageWidget

final class RefreshSpinTests: XCTestCase {
    func testRemainingExtendsAFastRefresh() {
        let start = Date(timeIntervalSince1970: 0)
        // The fetch finished 0.2s in; the spin must keep running ~0.8s more.
        let remaining = RefreshSpin.remaining(start: start, now: Date(timeIntervalSince1970: 0.2))
        XCTAssertEqual(remaining, 0.8, accuracy: 0.0001)
    }

    func testRemainingIsZeroOnceTheMinimumElapsed() {
        let start = Date(timeIntervalSince1970: 0)
        // The fetch took 1.5s — longer than the minimum, so no extra spin.
        let remaining = RefreshSpin.remaining(start: start, now: Date(timeIntervalSince1970: 1.5))
        XCTAssertEqual(remaining, 0, accuracy: 0.0001)
    }

    func testRemainingIsZeroWithoutAStart() {
        XCTAssertEqual(RefreshSpin.remaining(start: nil, now: Date()), 0)
    }
}
