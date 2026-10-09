import AppConfiguration
import AppCore
import CascadeKit
import FormatKit

public enum AppConfigurationKey: ServiceKey {
    public typealias Value = AppConfiguration
}

public enum FormatterServiceKey: ServiceKey {
    public typealias Value = FormatterService
}
