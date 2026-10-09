import Foundation
import Path

public protocol LinterRunner: Sendable {
    func execute(
        forPaths paths: [AbsolutePath],
        throwError: Bool,
        verbose: Bool
    ) throws
}

public struct LinterRunnerFactory: Sendable {
    public init() {}
    public func build(
        reportFormater: ReportFormater,
        from type: LinterType,
        linterSrvice: any LinterService
    ) -> any LinterRunner {
        LinterRunnerDefault(
            reportFormater: reportFormater,
            linterSrvice: linterSrvice,
            linterType: type
        )
    }
}
