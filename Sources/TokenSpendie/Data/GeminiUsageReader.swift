import Foundation

/// Counts Gemini CLI usage from its local log files. Gemini exposes no usage
/// API, so this scans `~/.gemini/tmp/<project>/logs.json` — the CLI's own
/// per-project prompt log. Best-effort: any unreadable file or malformed
/// record is skipped, never thrown.
struct GeminiUsageReader {
    private let geminiHome: URL
    /// Clock — injected so tests can pin "today".
    let now: () -> Date
    /// Calendar deciding the local-midnight day boundary.
    private let calendar: Calendar

    init(geminiHome: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".gemini", isDirectory: true),
         now: @escaping () -> Date = Date.init,
         calendar: Calendar = .current) {
        self.geminiHome = geminiHome
        self.now = now
        self.calendar = calendar
    }

    /// True if Gemini CLI OAuth credentials are present. A cheap file-existence
    /// check — never reads the secret, never prompts.
    func detectCredentials() -> Bool {
        FileManager.default.fileExists(
            atPath: geminiHome.appendingPathComponent("oauth_creds.json").path)
    }

    /// The next local midnight after `now()` — when the daily count resets.
    func nextLocalMidnight() -> Date {
        let startOfToday = calendar.startOfDay(for: now())
        return calendar.date(byAdding: .day, value: 1, to: startOfToday)
            ?? startOfToday
    }
}
