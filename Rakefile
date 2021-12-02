# frozen_string_literal: true

# Include default tasks like build, release, install etc. See https://github.com/rubygems/rubygems/blob/master/bundler/lib/bundler/gem_helper.rb#L46
require "bundler/gem_tasks"
require "rake/testtask"

# rspec: Testing framework. Adds 'spec' rake task.
# require "rspec/core/rake_task"
# RSpec::Core::RakeTask.new(:spec)

# rubocop: Linting. Adds 'rubocop' rake task.
require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop) do |t|
  # See https://docs.rubocop.org/rubocop/usage/basic_usage.html
  t.options = ["--display-cop-names", "--parallel"]
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  # t.verbose = true
end
desc "Run tests"

# default task: Add spec and rubocop to default tasks.
task default: %i[test rubocop]
