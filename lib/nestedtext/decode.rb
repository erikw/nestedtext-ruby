# frozen_string_literal: true

require "nestedtext/parser"
require "nestedtext/errors_internal"

require "logger"
require "stringio"

module NestedText
  # Decode a NestedText string to Ruby objects.
  #
  # [ntstring] The string containing NestedText to be decoded.
  # [top_class] Force the top level returned object to be of this type. Supported values are +Object+, +Array+, +Hash+ and +String+.
  # [strict] If strict mode should be used. +true+ or +false+.
  #
  # Returns the parsed object.
  #
  # Raises NestedText::Error if anything went wrong.
  def self.load(ntstring, top_class: Object, strict: false)
    raise Errors::WrongInputTypeError.new([String], ntstring) unless ntstring.nil? || ntstring.is_a?(String)

    Parser.new(StringIO.new(ntstring), top_class, strict: strict).parse
  end

  def self.load_file(filename, top_class: Object, strict: false)
    raise Errors::WrongInputTypeError.new([String], filename) unless !filename.nil? && filename.is_a?(String)

    # Open explicitly in text mode to detect \r as line ending.
    File.open(filename, mode = "rt") do |file|
      Parser.new(file, top_class, strict: strict).parse
    end
  end
end
