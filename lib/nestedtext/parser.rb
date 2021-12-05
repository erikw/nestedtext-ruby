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

      # TODO: break out to helper method so a unit test can test one line at a time.
      # TODO parse recusively and let parse methods use the line scanner when needed?
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
          result = {}
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
      result
    end

    private

    def parse_line_tag
      if @line_col == @cur_line.length
        @cur_line.tag = :blank
      elsif @cur_line[@line_col] == "#"
        @cur_line.tag = :comment
      elsif @cur_line[@line_col] == ":" && (@line_col == @cur_line.length - 1 || @cur_line[@line_col] == " ")
        @cur_line.tag = :key_item
      elsif @cur_line[@line_col] == "-" && (@line_col == @cur_line.length - 1 || @cur_line[@line_col] == " ")
        @cur_line.tag = :list_item
      elsif @cur_line[@line_col] == ">" && (@line_col == @cur_line.length - 1 || @cur_line[@line_col] == " ")
        @cur_line.tag = :string_item
      elsif @cur_line[@line_col] == "{"
        @cur_line.tag = :inline_dict
      elsif @cur_line[@line_col] == "["
        @cur_line.tag = :inline_list
      else
        # TODO: this regex must be tested. What are the constraints of the value?
        match = /^(?<key>\S[^\r\n]*?)\s*?:(?<value>.*)/.match @cur_line.line_content[@line_col..]
        if match
          @cur_line.tag = :dict_item
          @cur_line.key = match["key"]
          @cur_line.value = match["value"]
        else
          raise Errors::ParserNoLineTagDetected, @cur_line
        end
      end
      # TODO: handle the rest of the cases in if-else, and set Line.value to be rest of string depending on the line tag.
    end

    def parse_skip_leading_spaces
      @line_col += 1 while @line_col < @cur_line.length && /\s/.match(@cur_line[@line_col])
    end
  end
end
