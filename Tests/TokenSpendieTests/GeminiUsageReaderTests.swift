import XCTest
@testable import TokenSpendie

final class GeminiUsageReaderTests: XCTestCase {

    /// A throwaway ~/.gemini directory in the temp folder. `oauth` writes a
    /// stub `oauth_creds.json`; `projects` maps a project-dir name to the
    /// records its `logs.json` should contain.
    private func makeGeminiHome(oauth: Bool = false,
                                projects: [String: [[String: Any]]] = [:]) -> URL {
        let fm = FileManager.default
        let home = fm.temporaryDirectory
            .appendingPathComponent("gemini-\(UUID().uuidString)", isDirectory: true)
        try! fm.createDirectory(at: home, withIntermediateDirectories: true)
        if oauth {
            try! Data("{}".utf8)
                .write(to: home.appendingPathComponent("oauth_creds.json"))
        }
        for (name, records) in projects {
            let dir = home.appendingPathComponent("tmp/\(name)", isDirectory: true)
            try! fm.createDirectory(at: dir, withIntermediateDirectories: true)
            let data = try! JSONSerialization.data(withJSONObject: records)
            try! data.write(to: dir.appendingPathComponent("logs.json"))
        }
        return home
    }

    /// A UTC calendar so date-boundary tests do not depend on the runner's TZ.
    private var utcCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }

    func testDetectCredentialsTrueWhenOAuthFileExists() {
        let reader = GeminiUsageReader(geminiHome: makeGeminiHome(oauth: true))
        XCTAssertTrue(reader.detectCredentials())
    }

    func testDetectCredentialsFalseWhenNoOAuthFile() {
        let reader = GeminiUsageReader(geminiHome: makeGeminiHome(oauth: false))
        XCTAssertFalse(reader.detectCredentials())
    }

    func testNextLocalMidnightIsStartOfTomorrow() {
        let noon = Date(timeIntervalSince1970: 1_747_915_200) // 2025-05-22 12:00 UTC
        let reader = GeminiUsageReader(geminiHome: makeGeminiHome(),
                                       now: { noon },
                                       calendar: utcCalendar)
        // 2025-05-23 00:00 UTC
        XCTAssertEqual(reader.nextLocalMidnight(),
                       Date(timeIntervalSince1970: 1_747_958_400))
    }
}
