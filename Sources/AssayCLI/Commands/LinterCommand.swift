import App
import ArgumentParser
import Foundation
import LinterKit
import Path

struct LinterCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "linter",
        abstract: "A dedicated documentations sub-command tool",
        discussion: "",
        subcommands: [
            DocumentationLinter.self,
            CodeLinter.self
        ]
    )
}

private struct LinterOptions: ParsableArguments {
    @Argument(
        help: "Files to linter",
        completion: .directory
    )
    var paths: [AbsolutePath]

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
        name: [.customLong("swiftlint-bin")],
        help: ArgumentHelp(
            "SwiftLint bin path location, this is deprecated and will be removed in a future version.",
            discussion: "This option is deprecated and will be removed in a future version, example: --swiftlint-bin $(which swiftlint)"
        )
    )
    var swiftlintBin: String?

    @Option(
        help: """
        The reporter type default is code-quality but you can choose between (console, json, code-quality) finally it will be generate a file if it is code-quality or json.
        """
    )
    var reporter: LinterType = .codeQuality

    @Flag(
        help: "Throw error if any linting error detected"
    )
    var throwError: Bool = false
}

extension LinterType: ExpressibleByArgument {}

private struct DocumentationLinter: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "documentation",
        abstract: "Lint swift documentation inside the sources codes",
        discussion: ""
    )

    @OptionGroup
    var options: LinterOptions

    @Flag(
        help: "Enable verbose mode"
    )
    var verbose: Bool = false

    init() {}

    func run() throws {
        let linterServiceFactory = app.make(LinterServiceFactoryKey.self)
        let reportFormaterFactory = app.make(ReportFormaterFactoryKey.self)
        let linterRunnerFactory = app.make(LinterRunnerFactoryKey.self)

        try LinterKitFactory(
            linterServiceFactory: linterServiceFactory,
            reportFormaterFactory: reportFormaterFactory,
            linterRunnerFactory: linterRunnerFactory
        )
        .documentationLinter(
            options.paths,
            reporter: options.reporter,
            throwError: options.throwError,
            reportsPath: options.reportPath,
            reportFileName: options.filename,
            runnerName: options.runnerName,
            verbose: verbose
        )
    }
}

private struct CodeLinter: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "code",
        abstract: "Lint swift code files inside the sources codes",
        discussion: ""
    )

    @OptionGroup
    var options: LinterOptions

    @Option(
        name: [.customLong("config-file")],
        help: ArgumentHelp(
            "Path to a custom .swiftlint.yml. Overrides the bundled configuration entirely.",
            discussion: """
            When set, the bundled com.raywenderlich.swiftlint.yml is ignored and SwiftLint runs with \
            only this file as configuration source.
            """
        ),
        completion: .file(extensions: ["yml", "yaml"]),
        transform: { try AbsolutePath(validating: $0, relativeTo: .currentWorkingDirectory) }
    )
    var configFile: AbsolutePath?

    @Flag(
        help: "Enable verbose mode"
    )
    var verbose: Bool = false

    init() {}

    func run() throws {
        let linterServiceFactory = app.make(LinterServiceFactoryKey.self)
        let reportFormaterFactory = app.make(ReportFormaterFactoryKey.self)
        let linterRunnerFactory = app.make(LinterRunnerFactoryKey.self)

        try LinterKitFactory(
            linterServiceFactory: linterServiceFactory,
            reportFormaterFactory: reportFormaterFactory,
            linterRunnerFactory: linterRunnerFactory
        )
        .lint(
            options.paths,
            reporter: options.reporter,
            throwError: options.throwError,
            reportsPath: options.reportPath,
            reportFileName: options.filename,
            runnerName: options.runnerName,
            configFile: configFile,
            verbose: verbose
        )
    }
}
