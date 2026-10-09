import App
import AppConfiguration
import CascadeKit

/// The shared application container (Vapor's `app`), owned by the executable.
///
/// Pre-registers a safe default feature-flags value so the CLI's synchronous
/// subcommand gating never traps before `configure(_:)` has run.
let app: Application = .init()
