import Foundation

public struct LinterConfiguration: Sendable {
    /// Folder names or paths that are always excluded from linting.
    /// `.build` is SPM's output directory; `DerivedData` is Xcode's.
    public var defaultExcludes: [String]

    public init(defaultExcludes: [String]) {
        self.defaultExcludes = defaultExcludes
    }
}

extension LinterConfiguration {
    public static var `default`: LinterConfiguration {
        LinterConfiguration(defaultExcludes: [".build", "DerivedData", "Carthage", "Pods"])
    }
}
