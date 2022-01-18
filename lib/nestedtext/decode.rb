# frozen_string_literal: true

require "nestedtext/parser"
require "nestedtext/errors"
require "nestedtext/helpers"

require "logger"
require "stringio"

module NestedText
  # TODO: allow optional io=nil that can be written to? Similar to JSON module
  def self.load(ntstring, top_class: Object, strict: true)
    # logger = Logger.new(STDOUT) # TODO: make this available to other classes in module. How avoid singleton?
    # logger.info "input=#{raw_input_string}"
    # logger.info "top=#{top}"

    raise Errors::WrongInputTypeError.new([String], ntstring) unless ntstring.nil? || ntstring.is_a?(String)

    assert_valid_top_level_type top_class

    Parser.new(StringIO.new(ntstring), top_class, strict: strict).parse
  end

  def self.load_file(filename, top_class: Object, strict: true)
    raise Errors::WrongInputTypeError.new([String], filename) unless filename.nil? || filename.is_a?(String)

    assert_valid_top_level_type top_class

    # Open explicitly in text mode to detect \r as line ending.
    File.open(filename, mode = "rt") do |file|
      Parser.new(file, top_class, strict: strict).parse
    end
  end
end
