import AppConfiguration
import CascadeKit
import FormatKit

/// One-stop dependency configuration, à la Vapor's `configure.swift`.
///
/// Register every service here, then run the app. Called once at startup, before
/// argument parsing. Feature flags are `.transient` so this resolved value always
/// replaces the default (no stale singleton cache).
public func configure(_ app: Application) async {
    let configuration = await ConfigurationLoader.resolve()

    app.register(AppConfigurationKey.self) { _ in configuration }
    app.register(FormatterServiceKey.self) { _ in
        Formatter.Factory.default
    }
}
