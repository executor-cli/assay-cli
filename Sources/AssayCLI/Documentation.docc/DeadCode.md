# Dead code

Find unused Swift code in a SwiftPM package with Periphery.

## Usage

```bash
assay deadcode [<path>] [options]
```

```bash
assay deadcode --reporter console
assay deadcode Packages/Feature --report-path reports --exclude Generated
```

`<path>` is the folder that contains `Package.swift`. Default: the current directory.

> Note: macOS only, SwiftPM packages only. The scanned package is built with the `swift` found first on `PATH`.

## Options

| Option | Description |
| --- | --- |
| `--reporter` | `code-quality` (default), `console` or `json`. |
| `--filename` | Name of the generated report. Default `gl-code-quality-report.json`. |
| `--report-path` | Folder for the report. Default: the current directory. |
| `--runner-name` | Prefix for the report name, typically the CI runner. Default: `CI_RUNNER_NAME` or empty. |
| `--exclude` | A folder name or path whose results are not reported. Repeatable. |
| `--verbose` | Print detailed information. |

`code-quality` and `json` write a report file. `console` prints to the terminal.

## Exit code

The command exits with an error when it finds at least one unused declaration, after writing the report. A clean scan exits 0.

## Excludes

The folders skipped are the union of the `linter.defaultExcludes` setting (`.build`, `DerivedData`, `Carthage` and `Pods` by default) and every `--exclude` flag. Excluded files are still indexed, so code they use is not reported as unused. See <doc:Configuration>.
