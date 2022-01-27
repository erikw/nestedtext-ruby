# frozen_string_literal: true

require_relative "lib/nestedtext/version"

Gem::Specification.new do |spec|
  spec.name          = "nestedtext"
  spec.version       = NestedText::VERSION
  spec.authors       = ["Erik Westrup"]
  spec.email         = ["erik.westrup@gmail.com"]

  spec.summary       = "A ruby library for the human friendly data format NestedText (https://nestedtext.org/)"
  spec.description   = "A ruby library for the human friendly data format NestedText (https://nestedtext.org/). There is support for decoding a NestedText file or string to Ruby data structures, as well as encoding Ruby objects to a NestedText file or string. Furthermore there is support for serialization and deserialization of custom classes. Support for v3.2.1 of the data format will all official tests passing."
  spec.homepage      = "https://github.com/erikw/nestedtext-ruby/"
  spec.license       = "MIT"
  spec.required_ruby_version = [">= 3.0", "< 4"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/erikw/nestedtext-ruby/"
  spec.metadata["changelog_uri"] = "https://github.com/erikw/nestedtext-ruby/blob/main/CHANGELOG.md"

  # For push to GitHub packages to work.
  # Reference: https://github.community/t/unable-to-push-rubygem-to-package-registry-the-expected-resource-was-not-found/14596/7
  spec.metadata = {
    "github_repo" => "git@github.com:erikw/nestedtext-ruby.git"
  }

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select do |f|
      f.match(%r{\A(?:lib/|CHANGELOG.md|CONTRIBUTING.md|LICENSE.txt|README.md|SECURITY.md|nestedtext.gemspec)})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "warning", "~> 1.2"
  spec.add_runtime_dependency "word_wrap", "~> 1.0"
end
