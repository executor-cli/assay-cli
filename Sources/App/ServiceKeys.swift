import AppConfiguration
import AppCore
import CascadeKit
import FormatKit
import LinterKit

public enum AppConfigurationKey: ServiceKey {
    public typealias Value = AppConfiguration
}

public enum FormatterServiceKey: ServiceKey {
    public typealias Value = FormatterService
}

public enum ReportFormaterFactoryKey: ServiceKey {
    public typealias Value = ReportFormaterFactory
}

public enum LinterRunnerFactoryKey: ServiceKey {
    public typealias Value = LinterRunnerFactory
}

public enum LinterServiceFactoryKey: ServiceKey {
    public typealias Value = LinterServiceFactory
}
