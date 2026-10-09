import CascadeKit
import Foundation
import Path

struct ReportFormaterJson: ReportFormater {
    private let fileName: String
    private let outputURL: AbsolutePath
    private let runnerName: String?

    @Dependency(\.createFileService)
    private var fileManager: CreateFileService

    @Dependency(\.printer)
    private var printer: any Printer

    init(
        runnerName: String? = nil,
        fileName: String = .documentationReportFileName,
        outputURL: AbsolutePath = .currentWorkingDirectory
    ) {
        self.runnerName = runnerName
        self.fileName = fileName
        self.outputURL = outputURL
    }

    func report(from data: Data, verbose: Bool) throws {
        let json = try JSONDecoder().decode([SwiftLintFile].self, from: data)

        try fileManager.createDirectory(
            atPath: outputURL.pathString,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let url = outputURL.appending(component: fileName.adding(prefix: runnerName))

        let data = try JSONEncoder().encode(json)

        printer.print(url.pathString)

        let result = fileManager.createFile(
            atPath: url.pathString,
            contents: data,
            attributes: nil
        )

        if verbose {
            guard !result else {
                return printer.print("✅ Json report saved to \(url.pathString)")
            }

            printer.print("❌ Json report file not created")
        }
    }
}
