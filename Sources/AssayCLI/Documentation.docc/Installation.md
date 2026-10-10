# Installation

Install `assay` from a release binary, a container image, or from source.

## Release binaries

Download the archive for your platform from the [GitHub releases](https://github.com/executor-cli/assay-cli/releases): `darwin-arm64`, `darwin-amd64`, `linux-x86_64` or `linux-arm64`. Extract it and put `assay` on your `PATH`.

## Container image

```bash
docker run --rm -v "$PWD":/work -w /work ghcr.io/executor-cli/assay-cli:latest assay linter code .
```

Tags follow the release version: `1.2.6`, `1.2`, `1` and `latest`.

## From source

Requires macOS 15 or later (or Linux) and Swift 6.3 or later.

```bash
git clone https://github.com/executor-cli/assay-cli.git
cd assay-cli
swift build -c release --product assay
```

The binary is written to `.build/release/assay`.
