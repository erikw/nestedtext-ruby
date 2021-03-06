# frozen_string_literal: true

require 'nestedtext/errors_internal'
require 'nestedtext/scanners'

module NestedText
  # A LL(1) recursive descent parser for inline NT types.
  class InlineParser # rubocop:disable Metrics/ClassLength
    def initialize(line)
      @inline_scanner = InlineScanner.new(line)
    end

    def parse
      result = parse_any
      unless @inline_scanner.empty?
        raise Errors::ParseInlineExtraCharactersAfterDelimiterError.new(@inline_scanner.line, @inline_scanner.pos,
                                                                        @inline_scanner.remaining)
      end
      result
    end

    private

    def parse_any
      return nil if @inline_scanner.peek.nil?

      consume_whitespaces # Leading
      result = case @inline_scanner.peek
               when '{'
                 parse_dict
               when '['
                 parse_list
               else # Inline string
                 parse_string
               end

      consume_whitespaces # Trailing
      result
    end

    def consume_whitespaces
      @inline_scanner.read_next while !@inline_scanner.empty? && [' ', "\t"].include?(@inline_scanner.peek)
    end

    def parse_key_last_char(key)
      last_char = @inline_scanner.read_next
      if last_char == '}' && key.empty?
        raise Errors::ParseInlineMissingValueError.new(@inline_scanner.line, @inline_scanner.pos - 1)
      end
      return if last_char == ':'

      raise Errors::ParseInlineDictKeySyntaxError.new(@inline_scanner.line, @inline_scanner.pos - 1, last_char)
    end

    def parse_key
      key = []
      until @inline_scanner.empty? || [':', '{', '}', '[', ']', ','].include?(@inline_scanner.peek)
        key << @inline_scanner.read_next
      end
      if @inline_scanner.empty?
        raise Errors::ParseInlineNoClosingDelimiterError.new(@inline_scanner.line,
                                                             @inline_scanner.pos)
      end
      parse_key_last_char(key)
      key.join.strip
    end

    def parse_dict_last_char
      last_char = @inline_scanner.read_next
      return if last_char == '}'

      raise Errors::ParseInlineDictSyntaxError.new(@inline_scanner.line,
                                                   @inline_scanner.pos - 1, last_char)
    end

    def parse_dict
      result = {}
      loop do
        @inline_scanner.read_next
        break if result.empty? && @inline_scanner.peek == '}'

        key = parse_key
        value = parse_any
        result[key] = value
        break unless @inline_scanner.peek == ','
      end
      if @inline_scanner.empty?
        raise Errors::ParseInlineNoClosingDelimiterError.new(@inline_scanner.line,
                                                             @inline_scanner.pos)
      end
      parse_dict_last_char
      result
    end

    def parse_list_last_char(result)
      last_char = @inline_scanner.read_next
      return unless last_char != ']'

      if result[-1] == ''
        raise Errors::ParseInlineMissingValueError.new(@inline_scanner.line,
                                                       @inline_scanner.pos - 1)
      else
        raise Errors::ParseInlineListSyntaxError.new(@inline_scanner.line,
                                                     @inline_scanner.pos - 1, last_char)
      end
    end

    def parse_list
      result = []
      loop do
        @inline_scanner.read_next
        break if result.empty? && @inline_scanner.peek == ']'

        result << parse_any
        break unless @inline_scanner.peek == ','
      end
      if @inline_scanner.empty?
        raise Errors::ParseInlineNoClosingDelimiterError.new(@inline_scanner.line,
                                                             @inline_scanner.pos)
      end
      parse_list_last_char(result)
      result
    end

    def parse_string
      inline_string = []
      until @inline_scanner.empty? || ['{', '}', '[', ']', ','].include?(@inline_scanner.peek)
        inline_string << @inline_scanner.read_next
      end
      inline_string.join.rstrip # Trim trailing whitespaces that lead up to next break point.
    end
  end
  private_constant :InlineParser
end
