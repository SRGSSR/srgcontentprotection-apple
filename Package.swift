// swift-tools-version:5.3

import PackageDescription

struct ProjectSettings {
    static let marketingVersion: String = "3.0.2"
}

let package = Package(
    name: "SRGContentProtection",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v9),
        .tvOS(.v12)
    ],
    products: [
        .library(
            name: "SRGContentProtection",
            targets: ["SRGContentProtection"]
        )
    ],
    dependencies: [
        .package(name: "SRGDiagnostics", url: "https://github.com/SRGSSR/srgdiagnostics-apple.git", .upToNextMinor(from: "3.0.0")),
        .package(name: "SRGNetwork", url: "https://github.com/SRGSSR/srgnetwork-apple.git", .upToNextMinor(from: "3.0.0"))
    ],
    targets: [
        .target(
            name: "SRGContentProtection",
            dependencies: ["SRGDiagnostics", "SRGNetwork"],
            resources: [
                .process("Resources")
            ],
            cSettings: [
                .define("MARKETING_VERSION", to: "\"\(ProjectSettings.marketingVersion)\"")
            ]
        ),
        .testTarget(
            name: "SRGContentProtectionTests",
            dependencies: ["SRGContentProtection"],
            cSettings: [
                .headerSearchPath("Private")
            ]
        )
    ]
)
