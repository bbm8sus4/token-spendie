import XCTest
@testable import TokenSpendie

final class RefreshIndicatorTests: XCTestCase {

    // MARK: - FetchingEllipsis

    private func dots(_ seconds: TimeInterval) -> Int {
        FetchingEllipsis.dotCount(at: Date(timeIntervalSinceReferenceDate: seconds))
    }

    func testDotCountCyclesOneToThree() {
        // period is 0.4s; sampled mid-window to avoid float-boundary ambiguity.
        XCTAssertEqual(dots(0.1), 1)   // tick 0
        XCTAssertEqual(dots(0.5), 2)   // tick 1
        XCTAssertEqual(dots(0.9), 3)   // tick 2
        XCTAssertEqual(dots(1.3), 1)   // tick 3 — wraps
        XCTAssertEqual(dots(1.7), 2)   // tick 4
    }

    func testDotCountIsStableWithinAPeriod() {
        // Any time inside the first 0.4s window stays at 1 dot.
        XCTAssertEqual(dots(0.05), 1)
        XCTAssertEqual(dots(0.39), 1)
    }
}
