# frozen_string_literal: true

require 'nestedtext/parser'
require 'nestedtext/errors_internal'

require 'logger'
require 'stringio'

module NestedText
  # Decode a NestedText string to Ruby objects.
  #
  # @param ntstring [String] The string containing NestedText to be decoded.
  # @param top_class [String] Force the top level returned object to be of this type. Supported values are `Object`, `Array`, `Hash` and `String`.
  # @param strict [Boolean] If strict mode should be used.
  #
  # @return [Object, nil] The parsed object.
  #
  # @raise [NestedText::Error] if anything went wrong.
  def self.load(ntstring, top_class: Object, strict: false)
    raise Errors::WrongInputTypeError.new([String], ntstring) unless ntstring.nil? || ntstring.is_a?(String)

    Parser.new(StringIO.new(ntstring), top_class, strict:).parse
  end

  # Decode a NestedText stored in a given file.
  #
  # @param filename [String] The file path to read NestedText to decode from.
  # @param top_class [String] Force the top level returned object to be of this type. Supported values are `Object`, `Array`, `Hash` and `String`.
  # @param strict [Boolean] If strict mode should be used.
  #
  # @return [Object, nil] The parsed object.
  #
  # @raise [NestedText::Error] if anything went wrong.
  # @raise [IOError] on issue opening `filename` for reading in text mode.
  def self.load_file(filename, top_class: Object, strict: false)
    raise Errors::WrongInputTypeError.new([String], filename) unless !filename.nil? && filename.is_a?(String)

    # Open explicitly in text mode to detect \r as line ending.
    File.open(filename, 'rt') do |file|
      Parser.new(file, top_class, strict:).parse
    end
  end
end
