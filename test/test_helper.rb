require "simplecov" # Must be before any application code. See conf in .simplecov

require "minitest/autorun"
require "minitest/reporters"
require "minitest/byebug" if ENV["DEBUG"] # Start as: $ DEBUG=1 rake test

# Must be before we require 'nextedtex', so that the gems are ignore before loading them.
require "warning"
Gem.path.each do |path|
  # From gem word_wrap:
  Warning.ignore(/wrapper.rb:\d+: warning: ambiguity between regexp and two divisions:/, path)
end

require "nestedtext"

# Colorized test reporter.
# Minitest::Reporters.use! # Annoying progress bar which messes up stdout/logging.
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
