import Foundation

/// Runtime defaults for driving the Assay CLI, resolved from configuration.
///
/// Plain `Sendable` data so any consumer (services, requests) can read the same
/// resolved values synchronously.
public struct AppConfiguration: Sendable {
    public var format: FormatConfiguration

    public init(
        format: FormatConfiguration = .default
    ) {
        self.format = format
    }
}
