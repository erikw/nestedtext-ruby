# TODO: simplecov
# require "simplecov" # Must be before any application code.
## Must be set for codeclimat reporter
# SimpleCov.command_name "test:bdd"

require "minitest/autorun"
require "minitest/reporters"

# Colorized test reporter.
Minitest::Reporters.use!

# TODO: conf minitest
# Minitest::Reporters.use! [
## Minitest::Reporters::SpecReporter.new,
# Minitest::Reporters::DefaultReporter.new
# ]
# Minitest::Reporters.use!(Minitest::Reporters::DefaultReporter.new)
