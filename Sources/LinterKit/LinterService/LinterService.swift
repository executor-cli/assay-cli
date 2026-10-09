import Foundation
import Path

public struct LinterServiceFactory: Sendable {
    public init() {}
    public func swiftLint(
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

public protocol LinterService: Sendable {
    func execute(
        forPaths paths: [AbsolutePath],
        reporter: LinterType,
        verbose: Bool
    ) throws -> Data
}
