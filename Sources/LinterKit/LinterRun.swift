import Foundation
import Path

/// Provides static methods for running different types of linters on Swift code
public enum LinterRun {
    /// Execute documentation linting to check for missing documentation comments
    ///
    /// This method lints Swift source files to identify missing or incomplete documentation comments
    /// using SwiftLint's `missing_docs` rule. It generates reports in various formats based on the
    /// specified reporter type.
    ///
    /// - Parameters:
    ///   - paths: The folders or files to be linted. Multiple paths can be provided for batch linting.
    ///   - reporter: The output format type (console, json, or code-quality). Defaults to `.console`.
    ///   - throwError: Whether to throw an error if linting violations are found. Defaults to `true`.
    ///   - reportsPath: The directory path where reports will be saved. Defaults to current working
    /// directory.
    ///   - reportFileName: Custom filename for the generated report. Defaults to empty string, which uses
    ///                     the default filename based on reporter type.
    ///   - runnerName: Prefix to add to report filenames, typically used to identify CI/CD runner.
    ///   - verbose: Enable verbose output mode to display detailed information about report generation.
    ///              Defaults to `true`.
    /// - Throws: An error if `throwError` is `true` and linting violations are found, or if the linting
    ///           process encounters an error.
    public static func documentationLinter(
        _ paths: [AbsolutePath],
        reporter: LinterType,
        throwError: Bool = false,
        reportsPath: AbsolutePath = .currentWorkingDirectory,
        reportFileName: String = .codeQualityReportFileName,
        runnerName: String? = nil,
        verbose: Bool = true
    ) throws {
        let service = LinterServiceFactory.swiftLint(
            fileResourceName: "swiftlint-missingdoc",
            onlyRule: ["missing_docs"]
        )
        let reporterService = ReportFormaterFactory.build(
            from: reporter,
            printer: PrinterFactory.create(),
            runnerName: runnerName,
            fileName: reportFileName,
            reportsPath: reportsPath
        )
        let runner = LinterRunnerFactory.build(
            reportFormater: reporterService,
            from: reporter,
            service: service
        )
        try runner.execute(
            forPaths: paths,
            throwError: throwError,
            verbose: verbose
        )
    }

    /// Execute code linting to check Swift code quality and style
    ///
    /// This method performs comprehensive Swift code linting using SwiftLint rules configured in
    /// `com.raywenderlich.swiftlint`. It checks for code quality issues, style violations, and
    /// best practice adherence.
    ///
    /// - Parameters:
    ///   - paths: The folders or files to be linted. Multiple paths can be provided for batch linting.
    ///   - reporter: The output format type (console, json, or code-quality). Defaults to `.console`.
    ///   - throwError: Whether to throw an error if linting violations are found. Defaults to `true`.
    ///   - reportsPath: The directory path where reports will be saved. Defaults to current working
    /// directory.
    ///   - reportFileName: Custom filename for the generated report. Defaults to empty string, which uses
    ///                     the default filename based on reporter type.
    ///   - runnerName: Prefix to add to report filenames, typically used to identify CI/CD runner.
    ///   - configFile: Optional path to a `.swiftlint.yml` that fully overrides the bundled
    ///                 configuration. When `nil`, the bundled `com.raywenderlich.swiftlint` config is used.
    ///   - verbose: Enable verbose output mode to display detailed information about report generation.
    ///              Defaults to `true`.
    /// - Throws: An error if `throwError` is `true` and linting violations are found, or if the linting
    ///           process encounters an error.
    public static func lint(
        _ paths: [AbsolutePath],
        reporter: LinterType,
        throwError: Bool = false,
        reportsPath: AbsolutePath = .currentWorkingDirectory,
        reportFileName: String = .codeQualityReportFileName,
        runnerName: String? = nil,
        configFile: AbsolutePath? = nil,
        verbose: Bool = true
    ) throws {
        let service = LinterServiceFactory.swiftLint(
            fileResourceName: "com.raywenderlich.swiftlint",
            configFilePath: configFile?.pathString
        )
        let reporterService = ReportFormaterFactory.build(
            from: reporter,
            printer: PrinterFactory.create(),
            runnerName: runnerName,
            fileName: reportFileName,
            reportsPath: reportsPath
        )
        let runner = LinterRunnerFactory.build(
            reportFormater: reporterService,
            from: reporter,
            service: service
        )
        try runner.execute(
            forPaths: paths,
            throwError: throwError,
            verbose: verbose
        )
    }
}
