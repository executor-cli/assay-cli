import AppCore
import Configuration

extension AppConfiguration {
    public init(config: ConfigReader) {
        self.init(
            format: FormatConfiguration(config: config.scoped(to: .format))
        )
    }
}

extension ConfigKey {
    fileprivate static let format: ConfigKey = .init(["format"])
}
