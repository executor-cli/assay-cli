import Foundation
import Path

struct LinterRunnerDefault: LinterRunner {
    private let reportFormater: any ReportFormater
    private let linterSrvice: any LinterService
    private let linterType: LinterType

    init(
        reportFormater: any ReportFormater,
        linterSrvice: any LinterService,
        linterType: LinterType
    ) {
        self.reportFormater = reportFormater
        self.linterSrvice = linterSrvice
        self.linterType = linterType
    }

    func execute(
        forPaths paths: [AbsolutePath],
        throwError: Bool,
        verbose: Bool
    ) throws {
        let results = try linterSrvice.execute(
            forPaths: paths,
            reporter: linterType,
            verbose: verbose
        )

        try reportFormater.report(from: results, verbose: verbose)

        let valueResults = String(data: results, encoding: .utf8) ?? ""

        if throwError, valueResults != "{}" {
            throw LinterError.detectedSwiftLintError
        }
    }
}
