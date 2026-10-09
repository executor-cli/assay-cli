// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "assay-cli",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/amine2233/cascade-kit.git", from: "1.0.0"),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git",
            from: "1.6.0"
        ),
        .package(
            url: "https://github.com/nicklockwood/SwiftFormat",
            from: "0.63.1"
        ),
        .package(
            url: "https://github.com/realm/SwiftLint",
            from: "0.60.0"
        ),
        .package(url: "https://github.com/apple/swift-configuration.git", from: "1.0.0"),
        .package(
            url: "https://github.com/tuist/Path",
            exact: "0.3.8"
        ),
        .package(
            url: "https://github.com/apple/swift-nio-ssl",
            from: "2.36.0"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "App",
            dependencies: [
                .target(name: "AppConfiguration"),
                .product(name: "CascadeKit", package: "cascade-kit")
            ]
        ),
        .target(
            name: "AppConfiguration",
            dependencies: [
                .product(name: "Configuration", package: "swift-configuration")
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "App",
                "AppConfiguration",
                .product(name: "CascadeKit", package: "cascade-kit")
            ]
        ),
        .testTarget(
            name: "AppConfigurationTests",
            dependencies: [
                "AppConfiguration",
                .product(name: "Configuration", package: "swift-configuration")
            ]
        ),
        .executableTarget(
            name: "AssayCLI",
            dependencies: [
                "App",
                "AppConfiguration",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CascadeKit", package: "cascade-kit")
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ]
        ),
        .testTarget(
            name: "AssayCLITests",
            dependencies: ["AssayCLI"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency")
            ]
        ),
        .target(
            name: "FormatKit",
            dependencies: [
                .product(name: "SwiftFormat", package: "SwiftFormat"),
                .product(name: "Path", package: "Path")
            ]
        ),
        .testTarget(
            name: "FormatKitTests"
        ),
        .target(
            name: "LinterKit",
            dependencies: [
                .product(name: "SwiftLintFramework", package: "SwiftLint"),
                .product(name: "Path", package: "Path"),
                .product(name: "NIOSSL", package: "swift-nio-ssl")
            ],
            resources: [
                .copy("Resources/lint-missing-docs.sh"),
                .copy("Resources/swiftlint-missingdoc.yml"),
                .copy("Resources/com.raywenderlich.swiftlint.yml")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "LinterKitTests",
            dependencies: [
                .target(name: "LinterKit")
            ],
            resources: [
                .copy("Resources")
            ]
        )
    ]
)
