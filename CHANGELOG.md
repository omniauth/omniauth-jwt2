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

- kettle-jem-template-20260720-005 - README Support & Community links now
  include RubyForum.
- kettle-jem-template-20260726-001 - Projects now include YARD lint
  configuration and documentation dependencies so documentation issues fail
  before generated docs are refreshed.
- kettle-jem-template-20260727-001 - Spec harness documentation now lists the
  RSpec helpers provided by `kettle-test`.
- kettle-jem-template-20260729-005 - Gemspec metadata now publishes this
  project's RubyForum tag as `mailing_list_uri`, and support docs link to the
  tagged RubyForum community alongside Discord.

### Changed

- kettle-jem-template-20260716-002 - Gemspecs now ship fewer repository-only
  files, reducing package noise for downstream packagers.
- kettle-jem-template-20260720-002 - Development Gemfiles now use the released
  `tree_sitter_language_pack` gem 1.13.3 or newer by default.
- kettle-jem-template-20260725-002 - Version specs now use `anonymous_loader` to
  cover `version.rb` without redefining constants, or are removed when version
  specs are not managed for the project.
- kettle-jem-template-20260728-001 - Generated Ruby workflows now use clearer
  setup-ruby-flash planning and can prepare appraisal-only jobs without
  installing the main Gemfile bundle.
- kettle-jem-template-20260801-001 - Generated README gem dashboard links now
  use ClickGems instead of BestGems.

### Deprecated

### Removed

### Fixed

- kettle-jem-template-20260720-003 - StructuredMerge Git diff driver config now
  uses the installed `smorg-rb` driver command.
- kettle-jem-template-20260725-001 - Release pull request branches beginning
  with `feature/release` now run JRuby and TruffleRuby workflows.
- kettle-jem-template-20260726-002 - Generated version files now document their
  version namespace and constants, reducing warning-only YARD lint output.
- kettle-jem-template-20260726-003 - Coverage upload steps now treat Coveralls,
  QLTY, and Codecov as optional, so provider outages do not fail CI when local
  coverage thresholds still pass.
- kettle-jem-template-20260728-002 - Generated RuboCop configs now ignore the
  same `gemfiles/vendor/bundle` tree as `.gitignore`, so vendored dependency
  installs are not reported as project lint debt.
- kettle-jem-template-20260728-003 - Generated dep-heads workflows now run
  TruffleRuby jobs with current RubyGems and Bundler, avoiding setup failures
  before the test suite starts.
- kettle-jem-template-20260728-004 - Generated dep-heads workflows now use the
  setup-ruby Bundler install path for direct appraisal Gemfiles, avoiding rv
  lockfile parser failures on Git and path dependencies.
- kettle-jem-template-20260728-005 - VersionGem bootstrap now creates the
  missing canonical version spec when a project only has shim namespace version
  specs.
- kettle-jem-template-20260729-001 - Generated JRuby 9.4 workflows now use the
  legacy manual bundle install path, avoiding setup-time Bundler full-index
  failures against `gem.coop`.
- kettle-jem-template-20260730-001 - Gemspec package file enumeration now runs
  relative to the gemspec directory, so release package contents stay correct
  even when the gemspec is loaded from another working directory.
- kettle-jem-template-20260801-002 - Generated RSpec helpers now normalize
  managed configuration block bindings structurally, preventing mixed block
  parameter names from producing invalid configuration after a merge.
- kettle-jem-template-20260801-003 - Generated project metadata and
  documentation now normalize configured underscore hostnames to valid
  hyphenated hostnames.
- kettle-jem-template-20260801-004 - Generated organization README logos now
  use GitHub's stable organization avatar endpoint instead of assuming a
  matching Galtzo-hosted asset exists.

- kettle-jem-template-20260802-001 - Devcontainer JSON files now merge as JSONC,
  preserving comments and trailing commas during template updates.

### Security

## [1.0.1] - 2026-07-14

- TAG: [v1.0.1][1.0.1t]
- COVERAGE: 98.84% -- 85/86 lines in 6 files
- BRANCH COVERAGE: 92.31% -- 24/26 branches in 6 files
- 10.53% documented

### Added

- Added support for JRuby 10.1 and TruffleRuby 34.0.

### Changed

- Retemplated generated project metadata, support documentation, CI workflows,
  binstubs, and development dependency floors with `kettle-jem` v7.0.0.

### Fixed

- Package configured license files in gem release file lists.

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

[Unreleased]: https://github.com/omniauth/omniauth-jwt2/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/omniauth/omniauth-jwt2/compare/v1.0.0...v1.0.1
[1.0.1t]: https://github.com/omniauth/omniauth-jwt2/releases/tag/v1.0.1
[1.0.0]: https://github.com/omniauth/omniauth-jwt2/compare/v0.1.1...v1.0.0
[1.0.0t]: https://github.com/omniauth/omniauth-jwt2/releases/tag/v1.0.0
[0.1.1]: https://github.com/omniauth/omniauth-jwt2/compare/2a0397c0592e25b1c518d2c41fcbb8628a255bdf...v0.1.1
[0.1.1t]: https://github.com/omniauth/omniauth-jwt2/releases/tag/v0.1.1
