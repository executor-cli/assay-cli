#!/usr/bin/env bash
# The repo's checks, same as CI's lint + test jobs. Exit 0 only when the branch is fit to review.
set -euo pipefail

mise run lint
# mise's Swift toolchain can't build against the macOS 27 SDK; Xcode's swift can. Linux keeps mise's.
if [ "$(uname -s)" = "Darwin" ]; then /usr/bin/swift test; else mise run test; fi
