# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [1.0.0] - 2026-06-18

- TAG: [v1.0.0][1.0.0t]
- COVERAGE: 98.84% -- 85/86 lines in 6 files
- BRANCH COVERAGE: 92.31% -- 24/26 branches in 6 files
- 10.53% documented

### Added

- Added top-level `require "omniauth-jwt2"` support for shim gems and direct
  gem-name requires.

### Fixed

- Relaxed the OpenSSL-unavailable spec to support both JWT internal HMAC
  namespaces used across supported Ruby and `jwt` dependency combinations.

## [0.1.1] - 2026-06-16

- TAG: [v0.1.1][0.1.1t]
- COVERAGE: 96.47% -- 82/85 lines in 5 files
- BRANCH COVERAGE: 90.91% -- 20/22 branches in 5 files
- 10.53% documented

### Added

- Retemplated the project with the current `kettle-jem`/`kettle-dev` stack,
  adding the generated multi-Ruby CI matrix, Appraisal setup, documentation,
  governance files, and release tooling.

### Changed

- Updated project metadata and documentation to make `omniauth-jwt2` the
  maintained canonical gem under the `omniauth` organization while preserving
  the public `OmniAuth::Strategies::JWT` API and `require "omniauth/jwt"` path.
- Moved the package version constant to the gem-name namespace
  `Omniauth::JWT2::Version::VERSION`, while keeping
  `Omniauth::JWT::Version::VERSION` as a compatibility alias.

### Removed

- Removed obsolete pre-template workflow and gemfile setup in favor of the
  generated modular gemfiles and Appraisals.

[Unreleased]: https://github.com/omniauth/omniauth-jwt2/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/omniauth/omniauth-jwt2/compare/v0.1.1...v1.0.0
[1.0.0t]: https://github.com/omniauth/omniauth-jwt2/releases/tag/v1.0.0
[0.1.1]: https://github.com/omniauth/omniauth-jwt2/compare/2a0397c0592e25b1c518d2c41fcbb8628a255bdf...v0.1.1
[0.1.1t]: https://github.com/omniauth/omniauth-jwt2/releases/tag/v0.1.1
