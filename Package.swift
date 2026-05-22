// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TokenSpendie",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "TokenSpendie", path: "Sources/TokenSpendie"),
        .testTarget(
            name: "TokenSpendieTests",
            dependencies: ["TokenSpendie"],
            path: "Tests/TokenSpendieTests"
        ),
    ]
)
