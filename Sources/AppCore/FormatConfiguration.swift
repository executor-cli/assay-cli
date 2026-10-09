import Foundation

public struct FormatConfiguration: Sendable {
    public var swiftVersion: String

    /// Folder names that are always excluded from formatting.
    /// `.build` is SPM's output directory; `DerivedData` is Xcode's.
    public var defaultExcludes: [String]

    public init(
        swiftVersion: String,
        defaultExcludes: [String]
    ) {
        self.swiftVersion = swiftVersion
        self.defaultExcludes = defaultExcludes
    }
}

extension FormatConfiguration {
    public static var `default`: FormatConfiguration {
        FormatConfiguration(
            swiftVersion: "6.1", defaultExcludes: [".build", "DerivedData"]
        )
    }
}
