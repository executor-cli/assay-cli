import Configuration

/// Runtime defaults for driving the Assay CLI, resolved from configuration.
///
/// Plain `Sendable` data so any consumer (services, requests) can read the same
/// resolved values synchronously.
public struct AppConfiguration: Sendable {
    public init() {}

    /// Reads the settings from a configuration reader.
    /// - Parameter config: The configuration Reader
    public init(config: ConfigReader) {}
}
