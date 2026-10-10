# Lint code

Check Swift code quality and style with SwiftLint.

## Usage

```bash
assay linter code <paths> [options]
```

```bash
assay linter code . --reporter console
assay linter code Sources --reporter code-quality --report-path reports --throw-error
```

## Options

| Option | Description |
| --- | --- |
| `--reporter` | `code-quality` (default), `console` or `json`. |
| `--filename` | Name of the generated report. Default `gl-code-quality-report.json`. |
| `--report-path` | Folder for the report. Default: the current directory. |
| `--runner-name` | Prefix for the report name, typically the CI runner. Default: `CI_RUNNER_NAME` or empty. |
| `--config-file` | A `.swiftlint.yml` that replaces the bundled configuration entirely. |
| `--exclude` | A folder name or path to skip. Repeatable. |
| `--throw-error` | Exit with an error when violations are found. |
| `--verbose` | Print detailed information. |

`code-quality` and `json` write a report file. `console` prints to the terminal.

## Excludes

The folders skipped are the union of the `linter.defaultExcludes` setting (`.build`, `DerivedData`, `Carthage` and `Pods` by default), every `--exclude` flag, and the `excluded` entries of the SwiftLint configuration in use. See <doc:Configuration>.
