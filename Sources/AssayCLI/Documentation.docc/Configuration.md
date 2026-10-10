# Configuration

Set defaults in a YAML or JSON file, or with environment variables.

## Sources

Settings are layered, highest precedence first:

1. Environment variables.
2. A project file in the working directory: `assay-cli.yml`, `assay-cli.yaml` or `assay-cli.json`.
3. A user file in `$XDG_CONFIG_HOME/assay` (when set to an absolute path) or `~/.config/assay`: `config.yml`, `config.yaml` or `config.json`.

In each location the first file found is used, in the order `yml`, `yaml`, `json`. A value missing from one layer falls through to the next, then to the built-in default. A malformed file is skipped with a warning on standard error.

## Settings

```yaml
format:
  swiftVersion: "6.1"
  defaultExcludes: [.build, DerivedData]
linter:
  defaultExcludes: [.build, DerivedData, Carthage, Pods]
```

| Key | Default | Used by |
| --- | --- | --- |
| `format.swiftVersion` | `6.1` | <doc:Format> |
| `format.defaultExcludes` | `.build`, `DerivedData` | <doc:Format> |
| `linter.defaultExcludes` | `.build`, `DerivedData`, `Carthage`, `Pods` | <doc:LinterCode>, <doc:LinterDocumentation> |

## Environment variables

A key becomes an upper-case variable with words separated by underscores. List values are comma separated.

```bash
FORMAT_SWIFT_VERSION=6.2 assay format .
LINTER_DEFAULT_EXCLUDES=Generated,Vendor assay linter code .
```
