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
      result = {} # TODO: Assume top level is dict for now
      until @line_scanner.empty?
        @cur_line = @line_scanner.next
        @line_col = 0
        parse_skip_leading_spaces
        indentation = @line_col
        parse_line_tag

        case @cur_line.tag
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
          # TODO: set value of line
          result = { a: :b }
        when :inline
          raise NotImplementedError
        end
      end
      result
    end

    private

    def parse_line_tag
      if @line_col == @cur_line.length
        @cur_line.tag = :blank
        # elsif @line_col == @cur_line.length @line_col < @cur_line.length -1 && @cur_line[@line_col + 1] ==
        # elsif @cur_line[@line_col] == ":" && (@line_col == @cur_line.length - 1 || @cur_line[@line_col] == " ")
        # @cur_line.tag = :key_item
      elsif @cur_line[@line_col] == "#"
        @cur_line.tag = :comment
      elsif @cur_line[@line_col] == ":" && (@line_col == @cur_line.length - 1 || @cur_line[@line_col] == " ")
        @cur_line.tag = :key_item
      elsif @cur_line[@line_col] == "-" && (@line_col == @cur_line.length - 1 || @cur_line[@line_col] == " ")
        @cur_line.tag = :list_item
      elsif @cur_line[@line_col] == ">" && (@line_col == @cur_line.length - 1 || @cur_line[@line_col] == " ")
        @cur_line.tag = :string_item
      end
    end

    def parse_skip_leading_spaces
      @line_col += 1 while @line_col < @cur_line.length && /\s/.match(@cur_line[@line_col])
    end
  end
end
