import CNIOBoringSSL
import Foundation
import NIOSSL
import Path
import SwiftLintFramework

struct LinterServiceSwiftLint: LinterService {
    private let jsonEncoder: JSONEncoder
    private let fileResourceName: String
    private let additionalConfiguration: [String: Any]
    private let onlyRule: [String]
    private let configFilePath: String?

    init(
        fileResourceName: String,
        additionalConfiguration: [String: Any],
        onlyRule: [String],
        jsonEncoder: JSONEncoder,
        configFilePath: String? = nil
    ) {
        self.jsonEncoder = jsonEncoder
        self.fileResourceName = fileResourceName
        self.additionalConfiguration = additionalConfiguration
        self.onlyRule = onlyRule
        self.configFilePath = configFilePath
    }

    func execute(
        forPaths paths: [Path.AbsolutePath],
        reporter: LinterType,
        verbose: Bool
    ) throws -> Data {
        let resolvedConfigPath = try resolveConfigPath()

        let ruleRegistry = RuleRegistry.shared
        ruleRegistry.register(rules: builtInRules + coreRules)

        let configuration: Configuration
        if configFilePath != nil {
            configuration = Configuration(configurationFiles: [resolvedConfigPath])
        } else {
            let parentConfiguration = Configuration(
                configurationFiles: [resolvedConfigPath]
            )
            configuration = try Configuration(
                parentConfiguration: parentConfiguration,
                dict: additionalConfiguration,
                ruleList: ruleRegistry.list,
                onlyRule: onlyRule
            )
        }

        let swiftFiles = paths.flatMap {
            configuration.lintableFiles(
                inPath: $0.pathString,
                forceExclude: false,
                excludeBy: .paths(excludedPaths: configuration.excludedPaths())
            )
        }

        let storage = RuleStorage()

        let violations = swiftFiles.parallelFlatMap {
            Linter(file: $0, configuration: configuration)
                .collect(into: storage)
                .styleViolations(using: storage)
        }

        return try generateData(violations: violations, type: reporter)
    }

    private func resolveConfigPath() throws -> String {
        if let configFilePath {
            guard FileManager.default.fileExists(atPath: configFilePath) else {
                throw LinterError.customConfigFileNotFound(path: configFilePath)
            }

            return configFilePath
        }
        guard let bundled = Bundle.module
            .path(forResource: fileResourceName, ofType: "yml")
        else { throw LinterError.missingSwiftLintYamlFile }

        return bundled
    }

    private static func generateFingerprint(_ violation: StyleViolation) -> String {
        let fingerprintLocation = Location(
            file: violation.location.relativeFile,
            line: violation.location.line,
            character: violation.location.character
        )

        return [
            "\(fingerprintLocation)",
            "\(violation.ruleIdentifier)"
        ].joined().sha256()
    }

    private func generateData(violations: [StyleViolation], type: LinterType) throws -> Data {
        if type == .codeQuality {
            let elements = generateCodeQualityReport(violations: violations)
            return try jsonEncoder.encode(elements)
        } else {
            let elements = generateSwiftLintReport(violations: violations)
            return try jsonEncoder.encode(elements)
        }
    }

    private func generateCodeQualityReport(violations: [StyleViolation]) -> [Codeclimate] {
        violations.map { violation in
            Codeclimate(
                check_name: violation.ruleName,
                description: violation.reason,
                engine_name: "SwiftLint",
                fingerprint: LinterServiceSwiftLint.generateFingerprint(violation),
                severity: violation.severity == .error ? "major" : "minor",
                type: "issue",
                location: Codeclimate.Location(
                    lines: Codeclimate.Location.Line(
                        begin: violation.location.line,
                        end: violation.location.line
                    ),
                    path: violation.location.relativeFile
                )
            )
        }
    }

    private func generateSwiftLintReport(violations: [StyleViolation]) -> [SwiftLintFile] {
        violations.map { violation in
            SwiftLintFile(
                character: violation.location.character,
                file: violation.location.file,
                line: violation.location.line,
                reason: violation.reason,
                rule_id: violation.ruleIdentifier,
                severity: violation.severity == .error ? "major" : "minor",
                type: violation.severity.rawValue
            )
        }
    }
}

extension String {
    fileprivate func sha256() -> String {
        let data = Array(utf8)
        var hash = [UInt8](repeating: 0, count: Int(SHA256_DIGEST_LENGTH))

        data.withUnsafeBufferPointer { buffer in
            _ = CNIOBoringSSL_SHA256(buffer.baseAddress, buffer.count, &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
