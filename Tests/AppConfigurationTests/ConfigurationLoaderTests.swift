import AppCore
import Foundation
import Testing
@testable import AppConfiguration

@Suite("ConfigurationLoader")
struct ConfigurationLoaderTests {
    private let project: URL
    private let home: URL

    init() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ConfigurationLoaderTests-\(UUID().uuidString)")
        self.project = root.appendingPathComponent("project")
        self.home = root.appendingPathComponent("home")
        try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            at: home.appendingPathComponent(".config/assay"),
            withIntermediateDirectories: true
        )
    }

    private func write(_ contents: String, to relativePath: String, in directory: URL) throws {
        try contents.write(
            to: directory.appendingPathComponent(relativePath),
            atomically: true,
            encoding: .utf8
        )
    }

    private func resolve(environment: [String: String] = [:]) async -> AppConfiguration {
        await ConfigurationLoader.resolve(
            environment: environment,
            currentDirectory: project.path,
            homeDirectory: home.path
        )
    }

    @Test("falls back to defaults when there is no file and no environment")
    func defaults() async {
        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == FormatConfiguration.default.swiftVersion)
        #expect(configuration.format.defaultExcludes == FormatConfiguration.default.defaultExcludes)
        #expect(configuration.linter.defaultExcludes == LinterConfiguration.default.defaultExcludes)
    }

    @Test("loads ~/.config/assay/config.yml")
    func userYAML() async throws {
        try write(
            """
            format:
              swiftVersion: "5.9"
            linter:
              defaultExcludes:
                - Generated
                - Vendor
            """,
            to: ".config/assay/config.yml",
            in: home
        )

        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == "5.9")
        #expect(configuration.linter.defaultExcludes == ["Generated", "Vendor"])
    }

    @Test("loads ~/.config/assay/config.json")
    func userJSON() async throws {
        try write(
            #"{ "format": { "swiftVersion": "5.10", "defaultExcludes": ["Pods"] } }"#,
            to: ".config/assay/config.json",
            in: home
        )

        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == "5.10")
        #expect(configuration.format.defaultExcludes == ["Pods"])
    }

    @Test("prefers config.yml over config.json in the same folder")
    func ymlBeatsJSON() async throws {
        try write("format:\n  swiftVersion: \"6.0\"\n", to: ".config/assay/config.yml", in: home)
        try write(#"{ "format": { "swiftVersion": "5.5" } }"#, to: ".config/assay/config.json", in: home)

        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == "6.0")
    }

    @Test("project file overrides the user file")
    func projectOverridesUser() async throws {
        try write("format:\n  swiftVersion: \"5.9\"\n", to: ".config/assay/config.yml", in: home)
        try write("format:\n  swiftVersion: \"6.2\"\n", to: "assay-cli.yml", in: project)

        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == "6.2")
    }

    @Test("keeps user values the project file does not set")
    func layersAreMerged() async throws {
        try write("linter:\n  defaultExcludes: [Vendor]\n", to: ".config/assay/config.yml", in: home)
        try write(#"{ "format": { "swiftVersion": "6.2" } }"#, to: "assay-cli.json", in: project)

        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == "6.2")
        #expect(configuration.linter.defaultExcludes == ["Vendor"])
    }

    @Test("environment overrides files")
    func environmentWins() async throws {
        try write("format:\n  swiftVersion: \"5.9\"\n", to: ".config/assay/config.yml", in: home)

        let configuration = await resolve(environment: ["FORMAT_SWIFT_VERSION": "6.3"])

        #expect(configuration.format.swiftVersion == "6.3")
    }

    @Test("ignores a malformed file and keeps the next layer")
    func malformedFileIsSkipped() async throws {
        try write("format: [unclosed", to: "assay-cli.yml", in: project)
        try write("format:\n  swiftVersion: \"5.9\"\n", to: ".config/assay/config.yml", in: home)

        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == "5.9")
    }

    @Test("lists existing files, project first")
    func filePathsOrder() throws {
        try write("{}", to: "assay-cli.json", in: project)
        try write("{}", to: ".config/assay/config.yaml", in: home)

        let paths = ConfigurationLoader.configFilePaths(
            environment: [:],
            currentDirectory: project.path,
            homeDirectory: home.path
        )

        #expect(paths == [
            project.appendingPathComponent("assay-cli.json").path,
            home.appendingPathComponent(".config/assay/config.yaml").path
        ])
    }

    @Test("XDG_CONFIG_HOME replaces ~/.config")
    func xdgConfigHome() async throws {
        let xdg = home.appendingPathComponent("custom-xdg")
        try FileManager.default.createDirectory(
            at: xdg.appendingPathComponent("assay"),
            withIntermediateDirectories: true
        )
        try write("format:\n  swiftVersion: \"6.4\"\n", to: "assay/config.yml", in: xdg)
        try write("format:\n  swiftVersion: \"5.9\"\n", to: ".config/assay/config.yml", in: home)

        let configuration = await resolve(environment: ["XDG_CONFIG_HOME": xdg.path])

        #expect(configuration.format.swiftVersion == "6.4")
    }

    @Test("a relative or empty XDG_CONFIG_HOME is ignored")
    func invalidXDGConfigHome() async throws {
        try write("format:\n  swiftVersion: \"5.9\"\n", to: ".config/assay/config.yml", in: home)

        for value in ["", "relative/dir"] {
            let configuration = await resolve(environment: ["XDG_CONFIG_HOME": value])
            #expect(configuration.format.swiftVersion == "5.9")
        }
    }

    @Test("loads a .yaml project file")
    func projectYAMLExtension() async throws {
        try write("linter:\n  defaultExcludes: [Generated]\n", to: "assay-cli.yaml", in: project)

        let configuration = await resolve()

        #expect(configuration.linter.defaultExcludes == ["Generated"])
    }

    @Test("project assay-cli.yml wins over assay-cli.json")
    func projectYMLBeatsJSON() async throws {
        try write("format:\n  swiftVersion: \"6.0\"\n", to: "assay-cli.yml", in: project)
        try write(#"{ "format": { "swiftVersion": "5.5" } }"#, to: "assay-cli.json", in: project)

        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == "6.0")
    }

    @Test("an environment variable can set a list, comma separated")
    func environmentList() async {
        let configuration = await resolve(environment: ["LINTER_DEFAULT_EXCLUDES": "Generated,Vendor"])

        #expect(configuration.linter.defaultExcludes == ["Generated", "Vendor"])
    }

    @Test("a file can set an empty exclude list")
    func fileEmptyList() async throws {
        try write("linter:\n  defaultExcludes: []\n", to: "assay-cli.yml", in: project)

        let configuration = await resolve()

        #expect(configuration.linter.defaultExcludes.isEmpty)
    }

    @Test("a file with unrelated content leaves the defaults")
    func unrelatedFile() async throws {
        try write("something:\n  else: true\n", to: ".config/assay/config.yml", in: home)

        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == FormatConfiguration.default.swiftVersion)
    }

    @Test("a malformed JSON file is skipped")
    func malformedJSON() async throws {
        try write("{ not json", to: "assay-cli.json", in: project)
        try write("format:\n  swiftVersion: \"5.9\"\n", to: ".config/assay/config.yml", in: home)

        let configuration = await resolve()

        #expect(configuration.format.swiftVersion == "5.9")
    }

    @Test("no file is listed when none exists")
    func noFiles() {
        let paths = ConfigurationLoader.configFilePaths(
            environment: [:],
            currentDirectory: project.path,
            homeDirectory: home.path
        )

        #expect(paths.isEmpty)
    }

    @Test("user config directory: XDG_CONFIG_HOME, else ~/.config")
    func userConfigDirectory() {
        #expect(
            ConfigurationLoader.userConfigDirectory(
                environment: ["XDG_CONFIG_HOME": "/xdg"],
                homeDirectory: "/home/me"
            )
                == "/xdg/assay"
        )
        #expect(
            ConfigurationLoader.userConfigDirectory(environment: [:], homeDirectory: "/home/me")
                == "/home/me/.config/assay"
        )
        #expect(
            ConfigurationLoader.userConfigDirectory(
                environment: ["XDG_CONFIG_HOME": "rel"],
                homeDirectory: "/home/me"
            )
                == "/home/me/.config/assay"
        )
    }
}
