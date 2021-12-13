require "simplecov" # Must be before any application code. See conf in .simplecov

require "minitest/autorun"
require "minitest/reporters"

require "nestedtext"

# Colorized test reporter.
# Minitest::Reporters.use! # Annoying progress bar which messes up stdout/logging.
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
