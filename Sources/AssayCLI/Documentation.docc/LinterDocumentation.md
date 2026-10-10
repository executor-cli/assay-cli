# Lint documentation

Find declarations that are missing documentation comments, using SwiftLint's `missing_docs` rule.

## Usage

```bash
assay linter documentation <paths> [options]
```

```bash
assay linter documentation Sources --reporter console
```

## Options

It accepts the same options as <doc:LinterCode>, except `--config-file`: `--reporter`, `--filename`, `--report-path`, `--runner-name`, `--exclude`, `--throw-error` and `--verbose`.

Only the `missing_docs` rule runs, with its own bundled configuration.
