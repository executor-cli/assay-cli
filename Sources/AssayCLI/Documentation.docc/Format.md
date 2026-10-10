# Format

Format Swift files and folders with a fixed SwiftFormat rule set.

## Usage

```bash
assay format <paths> [--exclude <name-or-path> ...]
```

`<paths>` are files or folders. Relative paths such as `.` are resolved against the current directory.

```bash
assay format .
assay format Sources Tests --exclude Generated
```

## Excludes

The folders skipped are the union of the `format.defaultExcludes` setting (`.build` and `DerivedData` by default) and every `--exclude` flag. An entry is a folder name or a path. Repeat the flag to exclude several entries.

The Swift version SwiftFormat targets comes from the `format.swiftVersion` setting. See <doc:Configuration>.
