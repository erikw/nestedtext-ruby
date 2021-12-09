# frozen_string_literal: true

require "stringio"

require "nestedtext/errors"
require "nestedtext/scanners"

module NestedText
  class Parser
    def initialize(raw_input, top)
      @raw_input = raw_input
      @top = top
      @line_scanner = LineScanner.new(StringIO.new(@raw_input))
      @cur_line = nil
      @line_col = 0
    end

    def parse
      result = _parse_any
    end

    private

    def _parse_any
      case @line_scanner.peek&.tag # Use Null Pattern instead with a EndOfInput tag?
      when :list_item
        raise NotImplementedError
      when :dict_item
        # TODO: set value of line
        # result = { a: :b }
        _parse_dict_item
      when :string_item
        raise NotImplementedError
      when :key_item
        raise NotImplementedError
      when :inline
        raise NotImplementedError
      end
    end

    def _parse_dict_item
      result = {}
      # @cur_line = @line_scanner.next
      while @line_scanner.peek&.tag == :dict_item  # just while hasNext pattern instead of peek?
        @cur_line = @line_scanner.next
        result[@cur_line.key] = @cur_line.value
      end
      result
    end
  end
end
