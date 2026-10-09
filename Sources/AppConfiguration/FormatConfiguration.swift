import AppCore
import Configuration
import Foundation

extension FormatConfiguration {
    public init(config: ConfigReader) {
        self.init(
            swiftVersion: config.string(
                forKey: .swiftVersion,
                default: "6.1"
            ),
            defaultExcludes: config.stringArray(
                forKey: .defaultExcludes,
                default: [".build", "DerivedData"]
            )
        )
    }
}

extension ConfigKey {
    fileprivate static let swiftVersion = ConfigKey(["swiftVersion"])
    fileprivate static let defaultExcludes = ConfigKey(["defaultExcludes"])
}
