// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TrackingApp",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "TrackingApp",
            path: "Sources/TrackingApp",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
