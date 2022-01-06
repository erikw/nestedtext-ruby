# vi: ft=ruby

SimpleCov.start do
  enable_coverage :branch # Add branch coverage statistics.
  # minimum_coverage 90             # Minimum coverage percentage. TODO enable
  # TODO still needed? is bdd correct name?
  # TODO could move this to .simplecov?
  command_name "test:bdd"           # Must be set for codeclimat reporter
  add_filter "test/official_tests/"	# Not part of project
end
