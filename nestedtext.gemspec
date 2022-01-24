# frozen_string_literal: true

require_relative "lib/nestedtext/version"

Gem::Specification.new do |spec|
  spec.name          = "nestedtext"
  spec.version       = NestedText::VERSION
  spec.authors       = ["Erik Westrup"]
  spec.email         = ["erik.westrup@gmail.com"]

  spec.summary       = "A ruby library for the human friendly data format NestedText https://nestedtext.org/"
  spec.description   = "A ruby implementation the NestedText data format. There is support for decoding a NestedText file or string to Ruby data structures, as well as encoding Ruby objects to a NestedText file or string. Furthermore there is support for serialization and deserialization of custom classes. Support for v3.1.0 of the data format will all official tests passing."
  spec.homepage      = "https://github.com/erikw/nestedtext-ruby/"
  spec.license       = "MIT"
  spec.required_ruby_version = [">= 3.0", "< 4"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/erikw/nestedtext-ruby/"
  spec.metadata["changelog_uri"] = "https://github.com/erikw/nestedtext-ruby/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test/|script/|\.github/|\.gitmodules|Rakefile|TODO\.txt|\.codeclimate\.yml|\.vimlocal|\.simplecov)})
    end
  end
  spec.require_paths = ["lib"]
end
