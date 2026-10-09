import ExecutorCore
import Foundation

protocol LinterRunner {
    func execute(
        forPaths paths: [AbsolutePath],
        throwError: Bool,
        verbose: Bool
    ) throws
}

enum LinterRunnerFactory {
    static func build(
        reportFormater: ReportFormater,
        from type: LinterType,
        service: any LinterService
    ) -> any LinterRunner {
        LinterRunnerDefault(
            reportFormater: reportFormater,
            service: service,
            linterType: type
        )
    }
}
