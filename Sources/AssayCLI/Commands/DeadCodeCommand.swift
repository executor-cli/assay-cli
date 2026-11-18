#if os(macOS)
import App
import AppCore
import ArgumentParser
import DeadCodeKit
import Foundation
import LinterKit
import Path

struct DeadCodeCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "deadcode",
        abstract: "Find unused Swift code in a SwiftPM package"
    )

    @Argument(
        help: "SwiftPM package folder to scan (default: current working directory)",
        completion: .directory
    )
    var path: AbsolutePath = .currentWorkingDirectory

    @Option(
        help: """
        The reporter type default is code-quality but you can choose between (console, json, code-quality) finally it will be generate a file if it is code-quality or json.
        """
    )
    var reporter: LinterType = .codeQuality

    @Option(
        help: "Filename of the generated report"
    )
    var filename: String = .codeQualityReportFileName

    @Option(
        help: "Report path (default: current working directory)",
        completion: .directory,
        transform: { try AbsolutePath(validating: $0, relativeTo: .currentWorkingDirectory) }
    )
    var reportPath: AbsolutePath = .currentWorkingDirectory

    @Option(
        help: "Name of the runner to use (default: is CI_RUNNER_NAME or empty string)"
    )
    var runnerName: String?

    @Option(
        name: [.customLong("exclude")],
        help: ArgumentHelp(
            "Files and Folders name or path to skip (repeatable).",
            discussion: """
            Merged with the configured defaults (.build, DerivedData, Carthage, Pods). \
            Pass multiple --exclude flags to exclude multiple folders.
            """
        ),
        completion: .directory
    )
    var exclude: [String] = []

    @Flag(
        help: "Enable verbose mode"
    )
    var verbose: Bool = false

    init() {}

    func run() throws {
        try DeadCodeInput.checkPackage(at: path.pathString)

        let configuration = app.make(AppConfigurationKey.self)
        let excludes = configuration.linter.defaultExcludes.merging(exclude)

        let reportFormater = app.make(ReportFormaterFactoryKey.self).build(
            from: reporter,
            runnerName: runnerName,
            fileName: filename,
            reportsPath: reportPath
        )

        let data = try DeadCodeScanner.scan(
            packagePath: path.pathString,
            reportExclude: DeadCodeInput.excludeGlobs(excludes),
            verbose: verbose
        )

        try DeadCodeReporter(reporter: reporter, reportFormater: reportFormater)
            .report(from: data, verbose: verbose)
    }
}
#endif
