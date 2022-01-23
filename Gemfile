# frozen_string_literal: true

# Put require=false on gem's that we don't need to import in code (cli exec only)

source "https://rubygems.org"

# Include dependencies from the .gemspec
gemspec

# Development dependencies
# Should rather be here than in the .gemspec
# Reference: https://github.com/rubygems/bundler/pull/7222
# However there's an argument for using gemspec too: https://bundler.io/guides/creating_gem.html#testing-our-gem
group :development, :test do
  gem "appraisal", "~> 2.4", require: false
  gem "gem-release", "~> 2.0", require: false
  gem "pry-byebug", "~> 3.9"
  gem "rake", "~> 13.0", require: false
  gem "solargraph", require: false
end

group :test do
  gem "minitest-byebug", "~> 0.0.3"
  gem "minitest-reporters", "~> 1.4", require: false
  gem "rubocop", "~> 1.18", require: false
  gem "rubocop-rake", "~> 0.6", require: false
  gem "simplecov", "~> 0.21", require: false
end

gem "warning", "~> 1.2"
gem "word_wrap", "~> 1.0"