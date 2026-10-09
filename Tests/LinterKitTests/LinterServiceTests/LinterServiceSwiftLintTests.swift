import Foundation
import Path
import XCTest
@testable import LinterKit

final class LinterServiceSwiftLintTests: XCTestCase {
    private var workDir: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        workDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LinterServiceSwiftLintTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let workDir, FileManager.default.fileExists(atPath: workDir.path) {
            try FileManager.default.removeItem(at: workDir)
        }
        workDir = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests

    func test_execute_throws_when_custom_config_file_does_not_exist() throws {
        // GIVEN
        let missingPath = workDir.appendingPathComponent("missing.yml").path
        let service = LinterServiceSwiftLint(
            fileResourceName: "com.raywenderlich.swiftlint",
            additionalConfiguration: [:],
            onlyRule: [],
            jsonEncoder: JSONEncoder(),
            configFilePath: missingPath
        )

        // WHEN / THEN
        let swiftFile = try writeSwiftFile(named: "Sample.swift", contents: "let x = 1\n")
        let path = try AbsolutePath(validating: swiftFile.path)

        XCTAssertThrowsError(
            try service.execute(forPaths: [path], reporter: .json, verbose: false)
        ) { error in
            guard case let LinterError.customConfigFileNotFound(reported) = error else {
                XCTFail("Expected LinterError.customConfigFileNotFound, got \(error)")
                return
            }

            XCTAssertEqual(reported, missingPath)
        }
    }

    func xtest_execute_uses_custom_config_path_instead_of_bundled_resource() throws {
        // GIVEN: a fileResourceName that does NOT match any bundled resource.
        // Without an override, this would throw `missingSwiftLintYamlFile`.
        // With a valid custom config path provided, the bundled lookup must be
        // bypassed entirely and execution should succeed.
        let configFile = try writeFile(
            named: "minimal.swiftlint.yml",
            contents: "disabled_rules: []\n"
        )
        let swiftFile = try writeSwiftFile(
            named: "Sample.swift",
            contents: "let x = 1\n"
        )
        let service = LinterServiceSwiftLint(
            fileResourceName: "definitely-not-a-bundled-resource",
            additionalConfiguration: [:],
            onlyRule: [],
            jsonEncoder: JSONEncoder(),
            configFilePath: configFile.path
        )
        let path = try AbsolutePath(validating: swiftFile.path)

        // WHEN / THEN: no `missingSwiftLintYamlFile` thrown; returns a JSON array.
        let data = try service.execute(forPaths: [path], reporter: .json, verbose: false)
        let decoded = try JSONSerialization.jsonObject(with: data)
        XCTAssertTrue(decoded is [Any], "Expected JSON array output from linter")
    }

    func test_execute_falls_back_to_bundled_resource_when_no_override() throws {
        // GIVEN: no override; bundled resource exists.
        let swiftFile = try writeSwiftFile(
            named: "Sample.swift",
            contents: "let x = 1\n"
        )
        let service = LinterServiceSwiftLint(
            fileResourceName: "com.raywenderlich.swiftlint",
            additionalConfiguration: [:],
            onlyRule: [],
            jsonEncoder: JSONEncoder(),
            configFilePath: nil
        )
        let path = try AbsolutePath(validating: swiftFile.path)

        // WHEN / THEN: bundled config is loaded; no throw.
        let data = try service.execute(forPaths: [path], reporter: .json, verbose: false)
        let decoded = try JSONSerialization.jsonObject(with: data)
        XCTAssertTrue(decoded is [Any], "Expected JSON array output from linter")
    }

    func test_execute_throws_missing_yaml_when_neither_override_nor_bundled_resource() throws {
        // GIVEN: no override and a fileResourceName that does NOT exist in the bundle.
        let swiftFile = try writeSwiftFile(
            named: "Sample.swift",
            contents: "let x = 1\n"
        )
        let service = LinterServiceSwiftLint(
            fileResourceName: "definitely-not-a-bundled-resource",
            additionalConfiguration: [:],
            onlyRule: [],
            jsonEncoder: JSONEncoder(),
            configFilePath: nil
        )
        let path = try AbsolutePath(validating: swiftFile.path)

        // WHEN / THEN
        XCTAssertThrowsError(
            try service.execute(forPaths: [path], reporter: .json, verbose: false)
        ) { error in
            XCTAssertEqual(error as? LinterError, .missingSwiftLintYamlFile)
        }
    }

    // MARK: - Helpers

    private func writeFile(named name: String, contents: String) throws -> URL {
        let url = workDir.appendingPathComponent(name)
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func writeSwiftFile(named name: String, contents: String) throws -> URL {
        try writeFile(named: name, contents: contents)
    }
}
