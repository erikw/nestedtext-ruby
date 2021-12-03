# frozen_string_literal: true

require "stringio"

require "nestedtext/errors"
require "nestedtext/scanners"

module NestedText
  extend self  # to make methods module public.

  class Decoder
    def initialize(raw_input)
      @raw_input = raw_input
      @line_scanner = LineScanner.new(StringIO.new(@raw_input))
    end

    def decode
      result = nil
      until @line_scanner.empty?
        line = @line_scanner.next
        case line.type
        when :comment
          raise NotImplementedError
        when :blank
          raise NotImplementedError
        when :list_item
          raise NotImplementedError
        when :dictionary_item
          raise NotImplementedError
        when :string_item
          raise NotImplementedError
        when :key_item
          result = { a: :b }
        when :inline
          raise NotImplementedError
        end
      end
      result
    end
  end

  def load(raw_input_string)
    decoder = Decoder.new(raw_input_string)
    decoder.decode
  end
end
