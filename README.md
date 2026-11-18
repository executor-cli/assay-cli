# assay

A small Swift CLI that formats and lints Swift code, built on [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) and [SwiftLint](https://github.com/realm/SwiftLint) as libraries (no separate binaries needed). On macOS it also finds unused code with [Periphery](https://github.com/executor-cli/periphery).

## Usage

```bash
assay format <paths> [--exclude <name-or-path> ...]
assay linter code <paths> [--reporter console|json|code-quality] [--exclude ...] [--config-file .swiftlint.yml] [--throw-error]
assay linter documentation <paths> [--reporter ...] [--exclude ...]
assay deadcode [<path>] [--reporter ...] [--exclude ...]   # macOS only
```

- `format` applies a fixed SwiftFormat rule set to the given files or folders.
- `linter code` runs SwiftLint with the bundled `com.raywenderlich.swiftlint.yml`, or your own file via `--config-file`.
- `linter documentation` checks missing doc comments (`missing_docs` rule).
- `deadcode` (macOS only) builds the SwiftPM package at `<path>` (default: current directory) and reports unused code found by Periphery. It exits non-zero when it finds any.
- `code-quality` reports are GitLab Code Quality JSON, written to `--report-path` (default: current directory).
- Relative paths such as `.` are resolved against the current directory.

## Excludes

Excluded folders are the union of:

1. the configured defaults (`.build`, `DerivedData`, `Carthage`, `Pods`),
2. every `--exclude` flag,
3. the `excluded` entries of the SwiftLint config in use (linter only).

`deadcode` applies items 1 and 2.

An entry without `/` matches any folder name; an entry with `/` matches as a path fragment.

## Configuration

Optional config files, YAML or JSON. Sources are layered, highest precedence first:

1. environment variables (`FORMAT_SWIFT_VERSION`, `LINTER_DEFAULT_EXCLUDES=a,b`, ...)
2. project file in the working directory: `assay-cli.yml`, `assay-cli.yaml` or `assay-cli.json`
3. user file in `$XDG_CONFIG_HOME/assay` (when set to an absolute path) or `~/.config/assay`: `config.yml`, `config.yaml` or `config.json`

In each location the first file found is used (`yml`, then `yaml`, then `json`). Values missing from a layer fall through to the next one, then to the built-in defaults. A malformed file is skipped with a warning on stderr.

```yaml
format:
  swiftVersion: "6.1"
  defaultExcludes: [.build, DerivedData]
linter:
  defaultExcludes: [.build, DerivedData, Carthage, Pods]
```

## Layout

| Target | Role |
| --- | --- |
| `AssayCLI` | Executable and `ArgumentParser` commands |
| `App` | Dependency wiring ([CascadeKit](https://github.com/amine2233/cascade-kit)) |
| `AppCore` / `AppConfiguration` | Configuration types and their loader |
| `FormatKit` | SwiftFormat service |
| `LinterKit` | SwiftLint service, runners and report formatters |
| `DeadCodeKit` | Periphery scan (macOS only) and mapping to the report formatters |

## Build and run

Requires macOS 15+ and Swift 6.1+.

```bash
swift build
swift run assay format .
swift test
```

The project pins Swift via `mise.toml`. If the pinned toolchain cannot read your Xcode SDK, override it locally in a git-ignored `mise.local.toml`.
