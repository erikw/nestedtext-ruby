# vi: ft=ruby

SimpleCov.start do
  enable_coverage :branch # Add branch coverage statistics.
  minimum_coverage 90 # Minimum coverage percentage.
  # TODO still needed? is bdd correct name?
  # TODO could move this to .simplecov?
  command_name "test:bdd"           # Must be set for codeclimat reporter
  add_filter "test/official_tests/"	# Not part of project

  # Code climate needs JSON output.
  # Need to do SimpleCov.formater instead of just formatter, to not trigger warning of useless assignment.
  if ENV["CI"]  # Set in GitHub Actions: https://docs.github.com/en/actions/learn-github-actions/environment-variables
    require "simplecov_json_formatter"
    SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
  else
    SimpleCov.formatter SimpleCov::Formatter::HTMLFormatter
  end
end
