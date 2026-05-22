import XCTest
@testable import TokenSpendie

final class ThemeTests: XCTestCase {
    func testFourThemes() {
        XCTAssertEqual(Theme.allCases.count, 4)
        XCTAssertTrue(Theme.allCases.contains(.default))
    }

    func testRawValueRoundTrip() {
        for theme in Theme.allCases {
            XCTAssertEqual(Theme(rawValue: theme.rawValue), theme)
        }
    }

    func testEachThemeHasDistinctTierColors() {
        for theme in Theme.allCases {
            XCTAssertNotEqual(theme.color(for: .calm), theme.color(for: .warn))
            XCTAssertNotEqual(theme.color(for: .warn), theme.color(for: .hot))
        }
    }

    func testThemesDifferFromEachOther() {
        XCTAssertNotEqual(Theme.default.color(for: .hot), Theme.ocean.color(for: .hot))
        XCTAssertNotEqual(Theme.ocean.color(for: .calm), Theme.sunset.color(for: .calm))
    }

    func testDisplayNames() {
        XCTAssertEqual(Theme.default.displayName, "Default")
        XCTAssertEqual(Theme.violet.displayName, "Violet")
    }
}
