# frozen_string_literal: true

# Include default tasks like build, release, install etc. See https://github.com/rubygems/rubygems/blob/master/bundler/lib/bundler/gem_helper.rb#L46
require "bundler/gem_tasks"
require "rake/testtask"

# rubocop: Linting. Adds 'rubocop' rake task.
require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop) do |t|
  # See https://docs.rubocop.org/rubocop/usage/basic_usage.html
  t.options = ["--display-cop-names", "--parallel"]
end

Rake::TestTask.new do |t|
  t.name = "test_internal"
  t.description = "Run internal tests"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"].reject { |t| t == "test/official_test.rb" }
  # t.verbose = true
end

Rake::TestTask.new do |t|
  t.name = "test_official"
  t.description = "Run official tests"
  t.libs << "test"
  t.test_files = FileList["test/official_test.rb"]
end

# The test tasks can be called like:
# $ rake test TEST=path/to/some_test.rb TESTOPTS="-n='/test_method_pattern/'"
# $ rake test F=path/to/some_test.rb M=test_method_pattern
ENV["TEST"] = ENV["F"] if ENV.key? "F"
ENV["TESTOPTS"] = "-n='/#{ENV["M"]}/'" if ENV.key? "M"
task :test
desc "Run all tests"
task test: %i[test_internal test_official]

# default task: Add spec and rubocop to default tasks.
task default: %i[test rubocop]
