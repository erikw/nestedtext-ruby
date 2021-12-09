# TODO: simplecov
# require "simplecov" # Must be before any application code.
## Must be set for codeclimat reporter
# SimpleCov.command_name "test:bdd"

require "minitest/autorun"
require "minitest/reporters"

require "nestedtext"

# Colorized test reporter.
# Minitest::Reporters.use! # Annoying progress bar which messes up stdout/logging.
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
