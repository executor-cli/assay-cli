import AppCore
import Configuration

extension LinterConfiguration {
    public init(config: ConfigReader) {
        self.init(
            defaultExcludes: config.stringArray(
                forKey: .defaultExcludes,
                default: LinterConfiguration.default.defaultExcludes
            )
        )
    }
}

extension ConfigKey {
    fileprivate static let defaultExcludes = ConfigKey(["defaultExcludes"])
}
