import Foundation
import Path

enum LinterServiceFactory {
    static func swiftLint(
        fileResourceName: String,
        additionalConfiguration: [String: Any] = [:],
        onlyRule: [String] = [],
        jsonEncoder: JSONEncoder = JSONEncoder(),
        configFilePath: String? = nil
    ) -> any LinterService {
        LinterServiceSwiftLint(
            fileResourceName: fileResourceName,
            additionalConfiguration: additionalConfiguration,
            onlyRule: onlyRule,
            jsonEncoder: jsonEncoder,
            configFilePath: configFilePath
        )
    }
}

protocol LinterService {
    func execute(
        forPaths paths: [AbsolutePath],
        reporter: LinterType,
        verbose: Bool
    ) throws -> Data
}
