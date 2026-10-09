#!/bin/bash
set -e

# helper script to detect missing docs without disturbing CI tooling
swiftlint --path "./Sources" --config "./swiftlint-missingdoc.yml" --quiet --strict
