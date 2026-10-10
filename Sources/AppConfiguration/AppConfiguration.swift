import AppCore
import Configuration

extension AppConfiguration {
    public init(config: ConfigReader) {
        self.init(
            format: FormatConfiguration(config: config.scoped(to: .format)),
            linter: LinterConfiguration(config: config.scoped(to: .linter))
        )
    }
}

extension ConfigKey {
    fileprivate static let format: ConfigKey = .init(["format"])
    fileprivate static let linter: ConfigKey = .init(["linter"])
}
