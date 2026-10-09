import Foundation

public enum LinterError: Error, Equatable, Sendable {
    case detectedSwiftLintError
    case missingSwiftLintYamlFile
    case customConfigFileNotFound(path: String)
}

extension LinterError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .detectedSwiftLintError:
            "SwiftLint detected violations."
        case .missingSwiftLintYamlFile:
            "Bundled SwiftLint configuration file is missing."
        case let .customConfigFileNotFound(path):
            "Provided --config-file path does not exist: \(path)"
        }
    }
}
