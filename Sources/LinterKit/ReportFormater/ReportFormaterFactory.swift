import Foundation
import Path

public struct ReportFormaterFactory: Sendable {
    public init() {}

    public func build(
        from type: LinterType,
        runnerName: String? = nil,
        fileName: String = .codeQualityReportFileName,
        reportsPath: AbsolutePath = .currentWorkingDirectory
    ) -> any ReportFormater {
        switch type {
        case .console:
            ReportFormaterConsole()
        case .json:
            ReportFormaterJson(
                runnerName: runnerName,
                fileName: fileName,
                outputURL: reportsPath
            )
        case .codeQuality:
            ReportFormaterCodeQuality(
                runnerName: runnerName,
                fileName: fileName,
                outputURL: reportsPath
            )
        }
    }
}
