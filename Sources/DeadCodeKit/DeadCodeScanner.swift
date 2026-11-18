#if os(macOS)
import Foundation
import Indexer
import Logger
import PeripheryConfiguration
import PeripheryKit
import ProjectDrivers
import Shared
import SourceGraph

public enum DeadCodeScanner {
    public static func scan(packagePath: String, reportExclude: [String], verbose: Bool) throws -> Data {
        // SPMProjectDriver builds the package in the current directory, and exclude globs are relative to it.
        FileManager.default.changeCurrentDirectoryPath(packagePath)

        let configuration = Configuration()
        configuration.reportExclude = reportExclude
        configuration.relativeResults = true
        configuration.buildFilenameMatchers()

        let logger = Logger(quiet: !verbose, verbose: verbose, colorMode: .never)
        let shell = ShellImpl(logger: logger)
        let swiftVersion = SwiftVersion(shell: shell)
        let graph = SourceGraph(configuration: configuration, logger: logger)

        let driver = try SPMProjectDriver(configuration: configuration, shell: shell, logger: logger)
        try driver.build()
        let plan = try driver.plan(logger: logger.contextualized(with: "index"))
        _ = try IndexPipeline(
            plan: plan,
            graph: SourceGraphMutex(graph: graph),
            logger: logger.contextualized(with: "index"),
            configuration: configuration,
            swiftVersion: swiftVersion
        ).perform()
        try SourceGraphMutatorRunner(
            graph: graph,
            logger: logger,
            configuration: configuration,
            swiftVersion: swiftVersion
        ).perform()

        let results = try OutputDeclarationFilter(configuration: configuration, logger: logger)
            .filter(ScanResultBuilder.build(for: graph, configuration: configuration), with: nil)
        let json = try OutputFormat.json.formatter.init(configuration: configuration, logger: logger)
            .format(results, colored: false) ?? "[]"
        return Data(json.utf8)
    }
}
#endif
