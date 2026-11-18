// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "assay-cli",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "assay", targets: ["AssayCLI"])
    ],
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
        .package(
            url: "https://github.com/apple/swift-configuration.git",
            from: "1.0.0",
            traits: [.defaults, "YAML"]
        ),
        .package(
            url: "https://github.com/tuist/Path",
            exact: "0.3.8"
        ),
        .package(
            url: "https://github.com/apple/swift-nio-ssl",
            from: "2.36.0"
        ),
        // swift-index-store uses unsafeFlags, so the fork can only be pinned by revision (tag 3.9.1).
        .package(
            url: "https://github.com/executor-cli/periphery",
            revision: "35987082581998e6dc4f4b0122f403e44a5697fb"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AppCore"
        ),
        .target(
            name: "App",
            dependencies: [
                .target(name: "AppCore"),
                .target(name: "AppConfiguration"),
                .target(name: "FormatKit"),
                .target(name: "LinterKit"),
                .product(name: "CascadeKit", package: "cascade-kit")
            ]
        ),
        .target(
            name: "AppConfiguration",
            dependencies: [
                .target(name: "AppCore"),
                .product(name: "Configuration", package: "swift-configuration")
            ]
        ),
        .testTarget(
            name: "AppConfigurationTests",
            dependencies: [
                .target(name: "AppConfiguration"),
                .target(name: "AppCore")
            ]
        ),
        .executableTarget(
            name: "AssayCLI",
            dependencies: [
                .target(name: "App"),
                .target(name: "DeadCodeKit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Path", package: "Path")
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
            name: "DeadCodeKit",
            dependencies: [
                .target(name: "AppCore"),
                .target(name: "LinterKit"),
                .product(name: "PeripheryKit", package: "periphery", condition: .when(platforms: [.macOS]))
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "DeadCodeKitTests",
            dependencies: [
                .target(name: "DeadCodeKit"),
                .target(name: "LinterKit")
            ]
        ),
        .target(
            name: "FormatKit",
            dependencies: [
                .target(name: "AppCore"),
                .product(name: "SwiftFormat", package: "SwiftFormat"),
                .product(name: "Path", package: "Path"),
                .product(name: "CascadeKit", package: "cascade-kit")
            ]
        ),
        .testTarget(
            name: "FormatKitTests",
            dependencies: [
                .target(name: "FormatKit"),
                .target(name: "AppCore"),
                .product(name: "Path", package: "Path")
            ]
        ),
        .target(
            name: "LinterKit",
            dependencies: [
                .target(name: "AppCore"),
                .product(name: "SwiftLintFramework", package: "SwiftLint"),
                .product(name: "Path", package: "Path"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "CascadeKit", package: "cascade-kit")
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
