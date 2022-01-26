# frozen_string_literal: true

require "nestedtext/parser"
require "nestedtext/errors"

require "logger"
require "stringio"

module NestedText
  def self.load(ntstring, top_class: Object, strict: false)
    raise Errors::WrongInputTypeError.new([String], ntstring) unless ntstring.nil? || ntstring.is_a?(String)

    Parser.new(StringIO.new(ntstring), top_class, strict: strict).parse
  end

  def self.load_file(filename, top_class: Object, strict: true)
    raise Errors::WrongInputTypeError.new([String], filename) unless !filename.nil? && filename.is_a?(String)

    # Open explicitly in text mode to detect \r as line ending.
    File.open(filename, mode = "rt") do |file|
      Parser.new(file, top_class, strict: strict).parse
    end
  end
end
