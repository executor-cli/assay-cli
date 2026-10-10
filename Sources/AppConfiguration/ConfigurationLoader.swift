import AppCore
import Configuration
import Foundation
import SystemPackage

/// Resolves configuration into an `AppConfiguration`.
///
/// Pure resolver: it layers a `ConfigReader` from, highest precedence first,
/// the environment, a project file in the working directory (`assay-cli.yml`/`.yaml`/`.json`) and a
/// user file in `$XDG_CONFIG_HOME/assay` or `~/.config/assay` (`config.yml`/`.yaml`/`.json`). Storage/caching
/// is the dependency
/// container's job — this stays free of any DI framework so it can be reused on its own.
public enum ConfigurationLoader {
    private static let projectFileBaseName = "assay-cli"
    private static let userFileBaseName = "config"
    private static let fileExtensions = ["yml", "yaml", "json"]

    public static func resolve(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        currentDirectory: String = FileManager.default.currentDirectoryPath,
        homeDirectory: String = NSHomeDirectory()
    ) async -> AppConfiguration {
        var providers: [any ConfigProvider] =
            [EnvironmentVariablesProvider(environmentVariables: environment)]
        let paths = configFilePaths(
            environment: environment,
            currentDirectory: currentDirectory,
            homeDirectory: homeDirectory
        )
        for path in paths {
            if let provider = await fileProvider(at: path) {
                providers.append(provider)
            }
        }
        return AppConfiguration(config: ConfigReader(providers: providers))
    }

    /// The config files that exist, highest precedence first. Only the first matching extension of
    /// each location is used (`yml`, then `yaml`, then `json`).
    static func configFilePaths(
        environment: [String: String],
        currentDirectory: String,
        homeDirectory: String
    ) -> [String] {
        let locations = [
            (directory: currentDirectory, baseName: projectFileBaseName),
            (
                directory: userConfigDirectory(environment: environment, homeDirectory: homeDirectory),
                baseName: userFileBaseName
            )
        ]
        return locations.compactMap { location in
            fileExtensions
                .map { "\(location.directory)/\(location.baseName).\($0)" }
                .first { FileManager.default.fileExists(atPath: $0) }
        }
    }

    /// `$XDG_CONFIG_HOME/assay`, or `~/.config/assay`. Per the XDG spec, an empty or relative
    /// `XDG_CONFIG_HOME` is ignored.
    static func userConfigDirectory(environment: [String: String], homeDirectory: String) -> String {
        if let xdgConfigHome = environment["XDG_CONFIG_HOME"], xdgConfigHome.hasPrefix("/") {
            return "\(xdgConfigHome)/assay"
        }
        return "\(homeDirectory)/.config/assay"
    }

    private static func fileProvider(at path: String) async -> (any ConfigProvider)? {
        do {
            if path.hasSuffix(".json") {
                return try await FileProvider<JSONSnapshot>(filePath: FilePath(path))
            }
            return try await FileProvider<YAMLSnapshot>(filePath: FilePath(path))
        } catch {
            // Malformed/unreadable config file: skip it, and warn on stderr (never stdout).
            FileHandle.standardError.write(Data("warning: ignoring config file \(path): \(error)\n".utf8))
            return nil
        }
    }
}
