import Configuration
import Foundation
import SystemPackage

/// Resolves configuration into `FeatureFlags`.
///
/// Pure resolver: it builds a `ConfigReader` from the environment (highest
/// precedence) layered over an optional JSON config file and returns the flags.
/// Storage/caching is the dependency container's job — this stays free of any
/// DI framework so it can be reused on its own.
public enum ConfigurationLoader {
    /// Default config file name, looked up in the current working directory.
    private static let defaultConfigFileName = "assay-cli.json"

    /// Builds a `ConfigReader` from the environment (highest precedence) layered
    /// over an optional JSON config file.
    private static func configReader() async -> ConfigReader {
        var providers: [any ConfigProvider] = [EnvironmentVariablesProvider()]
        if let fileProvider = await jsonFileProvider() {
            providers.append(fileProvider)
        }
        return ConfigReader(providers: providers)
    }

    private static func jsonFileProvider() async -> (any ConfigProvider)? {
        let path = defaultConfigFileName
        guard FileManager.default.fileExists(atPath: path) else { return nil }

        do {
            return try await FileProvider<JSONSnapshot>(filePath: FilePath(path))
        } catch {
            // Malformed/unreadable config file: fall back to env-only, and warn on
            // stderr (never stdout — serve mode reserves it for JSON-RPC).
            FileHandle.standardError.write(Data("warning: ignoring config file \(path): \(error)\n".utf8))
            return nil
        }
    }
}
