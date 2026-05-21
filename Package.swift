// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ClaudeUsageWidget",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "ClaudeUsageWidget", path: "Sources/ClaudeUsageWidget"),
        .testTarget(
            name: "ClaudeUsageWidgetTests",
            dependencies: ["ClaudeUsageWidget"],
            path: "Tests/ClaudeUsageWidgetTests"
        ),
    ]
)
