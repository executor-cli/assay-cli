import App
import ArgumentParser
import CascadeKit

/// Root command.
///
/// This single executable can be used two ways:
///
/// * As a plain CLI — subcommands run and print to stdout.
///   stdio so an MCP host (Claude, an IDE, …) can call the same features as tools.
///
/// Both share the same `Application` core, so there is one implementation per
/// feature and two ways to reach it.
struct AssayCLI: AsyncParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "assay",
            abstract: "A assay helper usable as a CLI.",
            version: appVersion,
            subcommands: [
                FormatCommand.self
            ]
        )
    }
}
