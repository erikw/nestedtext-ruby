# vi: ft=ruby

unless ENV['NO_COVERAGE']
  SimpleCov.start do
    enable_coverage :branch # Add branch coverage statistics.
    minimum_coverage 90 # Minimum coverage percentage.
    command_name 'test:internal' # Must be set for codeclimat reporter.
    add_filter 'test/official_tests_api.rb'
    add_filter 'test/official_tests/'	# Code is not part of project, don't analyze.

    # Code climate needs JSON output.
    # Need to do SimpleCov.formater instead of just formatter, to not trigger warning of useless assignment.
    if ENV['CI']  # Set in GitHub Actions: https://docs.github.com/en/actions/learn-github-actions/environment-variables
      require 'simplecov_json_formatter'
      SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
    else
      SimpleCov.formatter SimpleCov::Formatter::HTMLFormatter
    end
  end
end
