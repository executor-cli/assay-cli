import AppCore
import Configuration
import Foundation
import Testing
@testable import AppConfiguration

private func list(_ values: [String]) -> ConfigValue {
    ConfigValue(.stringArray(values), isSecret: false)
}

@Suite("AppConfiguration(config:)")
struct AppConfigurationTests {
    private func reader(_ values: [AbsoluteConfigKey: ConfigValue]) -> ConfigReader {
        ConfigReader(provider: InMemoryProvider(values: values))
    }

    @Test("reads the format and linter sections")
    func readsBothSections() {
        let configuration = AppConfiguration(config: reader([
            "format.swiftVersion": "5.9",
            "format.defaultExcludes": list(["Pods", "Vendor"]),
            "linter.defaultExcludes": list(["Generated"])
        ]))

        #expect(configuration.format.swiftVersion == "5.9")
        #expect(configuration.format.defaultExcludes == ["Pods", "Vendor"])
        #expect(configuration.linter.defaultExcludes == ["Generated"])
    }

    @Test("an empty config yields the defaults")
    func emptyConfigUsesDefaults() {
        let configuration = AppConfiguration(config: reader([:]))

        #expect(configuration.format.swiftVersion == FormatConfiguration.default.swiftVersion)
        #expect(configuration.format.defaultExcludes == FormatConfiguration.default.defaultExcludes)
        #expect(configuration.linter.defaultExcludes == LinterConfiguration.default.defaultExcludes)
    }

    @Test("a missing section does not affect the other one")
    func sectionsAreIndependent() {
        let configuration = AppConfiguration(config: reader(["linter.defaultExcludes": list(["Generated"])]))

        #expect(configuration.format.swiftVersion == FormatConfiguration.default.swiftVersion)
        #expect(configuration.linter.defaultExcludes == ["Generated"])
    }

    @Test("an explicit empty list disables the default excludes")
    func emptyListOverridesDefaults() {
        let configuration = AppConfiguration(config: reader([
            "format.defaultExcludes": list([]),
            "linter.defaultExcludes": list([])
        ]))

        #expect(configuration.format.defaultExcludes.isEmpty)
        #expect(configuration.linter.defaultExcludes.isEmpty)
    }

    @Test("a value of the wrong type falls back to the default")
    func wrongTypeFallsBack() {
        let configuration = AppConfiguration(config: reader(["format.swiftVersion": 6]))

        #expect(configuration.format.swiftVersion == FormatConfiguration.default.swiftVersion)
    }

    @Test("keys outside the known sections are ignored")
    func unknownKeysAreIgnored() {
        let configuration = AppConfiguration(config: reader([
            "other.swiftVersion": "1.0",
            "swiftVersion": "1.0",
            "defaultExcludes": list(["Nope"])
        ]))

        #expect(configuration.format.swiftVersion == FormatConfiguration.default.swiftVersion)
        #expect(configuration.linter.defaultExcludes == LinterConfiguration.default.defaultExcludes)
    }
}

@Suite("Defaults")
struct DefaultsTests {
    @Test("format defaults")
    func formatDefaults() {
        #expect(FormatConfiguration.default.swiftVersion == "6.1")
        #expect(FormatConfiguration.default.defaultExcludes == [".build", "DerivedData"])
    }

    @Test("linter defaults")
    func linterDefaults() {
        #expect(LinterConfiguration.default.defaultExcludes == [".build", "DerivedData", "Carthage", "Pods"])
    }

    @Test("AppConfiguration() combines both defaults")
    func appDefaults() {
        let configuration = AppConfiguration()

        #expect(configuration.format.swiftVersion == FormatConfiguration.default.swiftVersion)
        #expect(configuration.linter.defaultExcludes == LinterConfiguration.default.defaultExcludes)
    }

    @Test("the config-based initialisers agree with the static defaults on an empty reader")
    func readerDefaultsMatchStaticDefaults() {
        let reader = ConfigReader(provider: InMemoryProvider(values: [:]))

        #expect(FormatConfiguration(config: reader).swiftVersion == FormatConfiguration.default.swiftVersion)
        #expect(FormatConfiguration(config: reader).defaultExcludes == FormatConfiguration.default
            .defaultExcludes)
        #expect(LinterConfiguration(config: reader).defaultExcludes == LinterConfiguration.default
            .defaultExcludes)
    }
}

@Suite("Array.merging")
struct ArrayMergingTests {
    @Test("appends new elements after the existing ones")
    func appendsNewElements() {
        #expect([".build", "Pods"].merging(["Generated"]) == [".build", "Pods", "Generated"])
    }

    @Test("drops duplicates and keeps the first occurrence order")
    func dropsDuplicates() {
        #expect([".build", "Pods"].merging(["Pods", "Generated", "Generated"]) == [
            ".build",
            "Pods",
            "Generated"
        ])
    }

    @Test("merging nothing, or into nothing, is a no-op")
    func emptyOperands() {
        #expect([".build"].merging([]) == [".build"])
        #expect([String]().merging(["a", "b"]) == ["a", "b"])
    }
}
