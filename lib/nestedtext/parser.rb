# frozen_string_literal: true

require "stringio"

require "nestedtext/errors"
require "nestedtext/scanners"

module NestedText
  class Parser
    def initialize(raw_input)
      @raw_input = raw_input
      @line_scanner = LineScanner.new(StringIO.new(@raw_input))
      @cur_line = nil
      @line_col = 0
    end

    def parse
      result = _parse_any
    end

    private

    def _parse_any
      # TODO: how make sure that file with only blanks gives an empty dict back, or shold it do that, check with ntpy-test?
      @cur_line = @line_scanner.next # TODO: don't fetchline here, but in respective tag parse subroutine as needed.
      case @cur_line.tag
      when :list_item
        raise NotImplementedError
      when :dict_item
        # TODO: set value of line
        result = { a: :b }
      when :string_item
        raise NotImplementedError
      when :key_item
        raise NotImplementedError
      when :inline
        raise NotImplementedError
      end
    end
  end
end
