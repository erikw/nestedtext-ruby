# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.2.2] - 2022-02-12
### Fixed
- Better module documentation fix.

## [4.2.1] - 2022-02-12
### Fixed
- Better module documentation.

## [4.2.0] - 2022-02-08
### Fixed
- Proper Unicode character name lookup.

## [4.1.1] - 2022-01-28
### Fixed
- Don't trigger CI when CD will run all tests anyways.

## [4.1.0] - 2022-01-28
### Changed
- cd.yml now runs full tests before releasing new version, by using reusable workflows.

## [4.0.0] - 2022-01-28
### Changed
- **Breaking change**: Renamed `NTEncodeMixin` to `ToNTMixin`.
- All code linted with RuboCop

## [3.2.1] - 2022-01-27
### Fixed
- Fix logo at rubydoc.info

## [3.2.0] - 2022-01-27
### Changed
- Switch from rdoc formatting syntax to Markdown with Redcarpet to be able to render README.md properly.

## [3.1.0] - 2022-01-27
### Changed
- Switch from rdoc to YARD to match rubydoc.info that is used automatically for Gems uploaded to rubygems.org.

## [3.0.0] - 2022-01-27
### Added
- API documentation generated with rdoc.

### Fixed
- Removed leaked `NT_MIXIN` constant in core extensions.

### Changed
- **Breaking change**: `#to_nt` on `String`, `Array` and `Hash` is no longer strict by default for consistency an unexpected surprises e.g. when having an array of Custom Objects and calling the method on the array.
- Internal clean-up and simplifications on helper classes and methods.

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
- Renamed `ToNTMixing` to `ToNTMixin` .

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
- Iteration on CD GitHub Actions workflow.

## [0.3.0] - 2022-01-24
- Iteration on CD GitHub Actions workflow.

## [0.2.0] - 2022-01-24
- Iteration on CD GitHub Actions workflow.

## [0.1.0] - 2022-01-24
### Added
- Initial release. If this release works, an 1.0.0 will soon follow.
