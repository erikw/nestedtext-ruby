# frozen_string_literal: true

# Include default tasks like build, release, install etc. See https://github.com/rubygems/rubygems/blob/master/bundler/lib/bundler/gem_helper.rb#L46
require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"

# default task: Add spec and rubocop to default tasks.
task default: %i[test rubocop]

desc "Build steps to be used by ci runner"
# TODO: enable rubocop after fixing issues.
task ci: %i[test]

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

desc "run :test with DEBUG=1 set"
task :testd do
  ENV["DEBUG"] = "1"
  Rake::Task["test"].invoke
end

Rake::RDocTask.new do |rd|
  # rd.main = "README.rdoc" # TODO what is this
  # rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_files.include("lib/**/*.rb")
  # TODO: output to doc/ instead
end

# Call like:
# $ rake parse_file F=path/to/file.nt
desc "Run NT parser on a provided file."
task :parse_file do
  raise "Provide path to file to parse in envionment variable F" unless ENV.key? "F"

  cur_dir = File.dirname(__FILE__)
  sh "#{cur_dir}/test/app.rb #{ENV["F"]}"
end
