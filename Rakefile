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

# Can be called like
# rake test TEST=path/to/some_test.rb TESTOPTS="-n='/test_method_pattern/'"
# or hacked together a bit shorter like
# rake test F=path/to/some_test.rb M=test_method_pattern
Rake::TestTask.new do |t|
  ENV["TEST"] = ENV["F"] if ENV.key? "F"
  ENV["TESTOPTS"] = "-n='/#{ENV["M"]}/'" if ENV.key? "M"
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  # t.verbose = true
end
desc "Run tests"

# default task: Add spec and rubocop to default tasks.
task default: %i[test rubocop]
