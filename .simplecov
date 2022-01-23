# vi: ft=ruby

SimpleCov.start do
  enable_coverage :branch # Add branch coverage statistics.
  # minimum_coverage 90             # Minimum coverage percentage. TODO enable
  # TODO still needed? is bdd correct name?
  # TODO could move this to .simplecov?
  command_name "test:bdd"           # Must be set for codeclimat reporter
  add_filter "test/official_tests/"	# Not part of project

  # Code climate needs JSON output.
  if ENV["CI"]  # Set in GitHub Actions: https://docs.github.com/en/actions/learn-github-actions/environment-variables
    require "simplecov_json_formatter"
    formatter = SimpleCov::Formatter::JSONFormatter
  else
    formatter SimpleCov::Formatter::HTMLFormatter
  end
end
