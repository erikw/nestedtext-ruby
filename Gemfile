# frozen_string_literal: true

# Put require=false on gem's that we don't need to import in code (cli exec only)

source 'https://rubygems.org'

# Include dependencies from the .gemspec
gemspec

# Development dependencies
# Should rather be here than in the .gemspec
# Reference: https://github.com/rubygems/bundler/pull/7222
# However there's an argument for using gemspec too: https://bundler.io/guides/creating_gem.html#testing-our-gem
group :development do
  gem 'gem-release', '~> 2.0', require: false
  gem 'guard', '~> 2.18'
  gem 'guard-bundler', '~> 3.0'
  gem 'guard-minitest', '~> 2.4'
  gem 'guard-rubocop', '~> 1.5'
  gem 'guard-yard', '~> 2.2'
  gem 'pry-byebug', '~> 3.9'
  gem 'rake', '~> 13.0', require: false
  gem 'redcarpet', '~> 3.5' # To render GitHub flavored Markdown files with yard.
  gem 'solargraph', require: false
  gem 'webrick', '~> 1.7'
  gem 'yard', '0.9.37' # Use same as on https://www.rubydoc.info/ (see footer)
end

group :test do
  gem 'minitest-byebug', '~> 0.0.3'
  gem 'minitest-reporters', '~> 1.4', require: false
  gem 'rubocop', '~> 1.71', require: false
  gem 'rubocop-rake', '~> 0.7.1', require: false
  gem 'simplecov', '~> 0.21', require: false
end