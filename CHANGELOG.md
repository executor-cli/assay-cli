# [1.1.1](https://github.com/executor-cli/assay-cli/compare/1.1.0...1.1.1) (2026-11-16)


## Bug Fixes


* provide libxml2.so.2 for executor on Ubuntu 26.04 runners (#4) ([fc1d489](https://github.com/executor-cli/assay-cli/commit/fc1d489de53066becdad2c3ee93fe99bbd384581))
* install libcurl dev package before static Linux link ([e140d8c](https://github.com/executor-cli/assay-cli/commit/e140d8c76e670c0383a34acaf1a060cc6a9f3e1c))


# [1.1.0](https://github.com/executor-cli/assay-cli/compare/1.0.0...1.1.0) (2026-10-10)


## Features


* add DocC documentation catalog and GitHub Pages publishing (#2) ([b9ec3d2](https://github.com/executor-cli/assay-cli/commit/b9ec3d21b7cb0384f4b1eb7353b12c1791f531b5))
* support layered YAML/JSON config files with XDG user location ([adfbf93](https://github.com/executor-cli/assay-cli/commit/adfbf93179e0d475c5c82f7d269b6ff3b80d21c1))


## Bug Fixes


* scope executor-cli tool to the tasks that need it ([5a07da1](https://github.com/executor-cli/assay-cli/commit/5a07da1d699b11b382c3599119e88a24e71d7910))
* generate binaries on all machines fail (#3) ([c3655ab](https://github.com/executor-cli/assay-cli/commit/c3655ab402fe3e70332df97de49e8bed97451030))
* bump shared CI workflow to 1.1.1 ([81f82fc](https://github.com/executor-cli/assay-cli/commit/81f82fc58915b0d9e133ebcc729d93eeaa6e6035))


# 1.0.0 (2026-10-10)


## Features


* add floating semver tags to Docker manifest for stable releases ([002c56c](https://github.com/executor-cli/assay-cli/commit/002c56c40de9fe989ac9266a08366707a0df78f1))
* add CI and release-binaries workflows with multi-arch image ([836fc0a](https://github.com/executor-cli/assay-cli/commit/836fc0a7190f8af65ad4a7afd690d0b3c4abee33))
* add multi-stage Dockerfile to build and run assay CLI ([2da4b93](https://github.com/executor-cli/assay-cli/commit/2da4b93d56be8ff8d36bc4be0b8d4f1f3f4f7a4a))
* add linter command with documentation and code subcommands ([02fa3ec](https://github.com/executor-cli/assay-cli/commit/02fa3ecedda62d6844242b3d706864eb073329d4))
* add format command backed by configurable FormatterService ([229487f](https://github.com/executor-cli/assay-cli/commit/229487f82e72adb82728d2b9dd08d7d2ab248d7a))
* bootstrap assay CLI package with linter, formatter and app scaffolding ([84e3c6a](https://github.com/executor-cli/assay-cli/commit/84e3c6a1b0fa1528f8210df5184b1c2ad848f747))


## Bug Fixes


* bump Swift toolchain from 6.1.1 to 6.3.3 ([c3d43a6](https://github.com/executor-cli/assay-cli/commit/c3d43a6180974defa42fc229c5b15b328219e4d4))
* force HTTP/1.1 for git to avoid HTTP/2 stream cancels ([b138d7e](https://github.com/executor-cli/assay-cli/commit/b138d7e852f6aecd5818f6d359a2077632b78f23))
* exclude build and dependency folders from SwiftLint runs ([16fe692](https://github.com/executor-cli/assay-cli/commit/16fe6929ab274aff9b010c459bd9698a45b9f71b))


