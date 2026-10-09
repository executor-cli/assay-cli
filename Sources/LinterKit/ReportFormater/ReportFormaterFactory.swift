import Foundation
import Path

enum ReportFormaterFactory {
    static func build(
        from type: LinterType,
        printer: any Printer,
        runnerName: String? = nil,
        fileName: String = .codeQualityReportFileName,
        reportsPath: AbsolutePath = .currentWorkingDirectory,
        fileManager: CreateFileService = FileManager.default
    ) -> any ReportFormater {
        switch type {
        case .console:
            ReportFormaterConsole(
                printer: printer
            )
        case .json:
            ReportFormaterJson(
                printer: printer,
                runnerName: runnerName,
                fileName: fileName,
                outputURL: reportsPath,
                fileManager: fileManager
            )
        case .codeQuality:
            ReportFormaterCodeQuality(
                printer: printer,
                runnerName: runnerName,
                fileName: fileName,
                outputURL: reportsPath,
                fileManager: fileManager
            )
        }
    }
}
