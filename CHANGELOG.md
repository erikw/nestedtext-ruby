# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- API documentation generated with rdoc.

### Fixed
- Removed leaked `NT_MIXIN` constant in core extensions.

### Changed
- **Breaking change**: `#to_nt` on `String`, `Array` and `Hash` is no longer strict by default for consistency an unexpected surprises e.g. when having an array of CustomObjects and calling the method on the array.

## [2.1.0] - 2022-01-27
### Changed
- Slim down Gem by using include instead of block list.

## [2.0.1] - 2022-01-26
### Fixed
- README issue with logo showing up on Rdoc (out-commented HTML).

## [2.0.0] - 2022-01-26
### Changed
- **Breaking change**: strict mode now defaults to false for both the `load` and `dump` methods.
- Internal rename of error classes to be more consistent.
- Internal simplification of argument passing.

## [1.2.0] - 2022-01-25
### Changed
- Hide core extension `String.normalize_line_endings` from users.

## [1.1.1] - 2022-01-25
### Fixed
- Renamed `NTEncodeMixing` to `NTEncodeMixin` .

## [1.1.0] - 2022-01-25
### Added
- Expose `NestedText::VERSION` for convenience to the users.

## [1.0.0] - 2022-01-25
The library is now useful for users!

### Changed
- Hide all internals in the module from users.

## [0.6.0] - 2022-01-24
### Fixed
- Move runtime dependencies from Gemfile to .gemspec.

## [0.5.0] - 2022-01-24
### Added
- Publish Gem to GitHub Packages

## [0.4.0] - 2022-01-24
- Iteration on CD GitHub Actins workflow.

## [0.3.0] - 2022-01-24
- Iteration on CD GitHub Actins workflow.

## [0.2.0] - 2022-01-24
- Iteration on CD GitHub Actins workflow.

## [0.1.0] - 2022-01-24
### Added
- Initial release. If this release works, an 1.0.0 will soon follow.
