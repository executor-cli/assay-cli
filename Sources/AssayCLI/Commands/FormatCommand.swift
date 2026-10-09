import App
import ArgumentParser
import FormatKit
import Foundation
import Path

struct FormatCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "format",
        abstract: "Format swift code",
        discussion: "Format the swift files in a given directory in order to follow basic syntaxic rules. Usage: 'mint run ntmo format Foo/'."
    )

    @Argument(
        help: "Files & Folders to format",
        completion: .directory
    )
    var paths: [AbsolutePath]

    @Option(
        name: [.customLong("exclude")],
        help: ArgumentHelp(
            "Files and Folders name or path to skip (repeatable).",
            discussion: """
            Builds on the built-in defaults (.build, DerivedData). Pass multiple --exclude flags \
            to exclude multiple folders, e.g. --exclude Carthage --exclude Generated.
            """
        ),
        completion: .directory
    )
    var exclude: [String] = []

    init() {}

    func run() throws {
        let configuration = app.make(AppConfigurationKey.self)
        let formatterService = app.make(FormatterServiceKey.self)

        try formatterService.format(
            paths,
            configuration: configuration,
            exclude: exclude
        )
    }
}

extension AbsolutePath: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        guard let currentDirectory = try? AbsolutePath(validating: FileManager.default.currentDirectoryPath),
              let resolved = try? AbsolutePath(validating: argument, relativeTo: currentDirectory)
        else { return nil }

        self = resolved
    }
}
