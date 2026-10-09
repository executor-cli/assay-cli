import Foundation
import Path

struct ReportFormaterCodeQuality: ReportFormater {
    private let fileName: String
    private let outputURL: AbsolutePath
    private let fileManager: CreateFileService
    private let printer: any Printer
    private let runnerName: String?

    init(
        printer: any Printer,
        runnerName: String? = nil,
        fileName: String = .codeQualityReportFileName,
        outputURL: AbsolutePath = .currentWorkingDirectory,
        fileManager: CreateFileService = FileManager.default
    ) {
        self.printer = printer
        self.runnerName = runnerName
        self.fileName = fileName
        self.outputURL = outputURL
        self.fileManager = fileManager
    }

    func report(from data: Data, verbose: Bool) throws {
        let json = try JSONDecoder().decode([Codeclimate].self, from: data)

        try fileManager.createDirectory(
            atPath: outputURL.pathString,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let url = outputURL.appending(component: fileName.adding(prefix: runnerName))

        let data = try JSONEncoder().encode(json)

        var jsonString = String(data: data, encoding: .utf8)
        jsonString?.replace("minor", with: "MINOR")
        jsonString?.replace("major", with: "MAJOR")

        let result = fileManager.createFile(
            atPath: url.pathString,
            contents: jsonString?.data(using: .utf8),
            attributes: nil
        )

        if verbose {
            guard !result else {
                return printer.print("✅ Code quality report saved to \(url.pathString)")
            }

            printer.print("❌ Code quality report file not created")
        }
    }
}
