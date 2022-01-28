# frozen_string_literal: true

require 'nestedtext/errors_internal'
require 'nestedtext/scanners'

module NestedText
  # A LL(1) recursive descent parser for NT.
  class InlineParser
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

    def parse_key
      key = []
      until @inline_scanner.empty? || [':', '{', '}', '[', ']', ','].include?(@inline_scanner.peek)
        key << @inline_scanner.read_next
      end
      if @inline_scanner.empty?
        raise Errors::ParseInlineNoClosingDelimiterError.new(@inline_scanner.line,
                                                             @inline_scanner.pos)
      end

      last_char = @inline_scanner.read_next
      if last_char == '}' && key.empty?
        raise Errors::ParseInlineMissingValueError.new(@inline_scanner.line, @inline_scanner.pos - 1)
      end
      unless last_char == ':'
        raise Errors::ParseInlineDictKeySyntaxError.new(@inline_scanner.line, @inline_scanner.pos - 1, last_char)
      end

      key.join.strip
    end

    def parse_any
      return nil if @inline_scanner.peek.nil?

      result = nil
      # Trim leading whitespaces
      @inline_scanner.read_next while !@inline_scanner.empty? && [' ', "\t"].include?(@inline_scanner.peek)
      case @inline_scanner.peek
      when '{'
        result = {}
        first = true
        loop do
          @inline_scanner.read_next
          break if first && @inline_scanner.peek == '}'

          first = false
          key = parse_key
          value = parse_any
          result[key] = value
          break unless @inline_scanner.peek == ','
        end
        if @inline_scanner.empty?
          raise Errors::ParseInlineNoClosingDelimiterError.new(@inline_scanner.line,
                                                               @inline_scanner.pos)
        end
        last_char = @inline_scanner.read_next
        unless last_char == '}'
          raise Errors::ParseInlineDictSyntaxError.new(@inline_scanner.line, @inline_scanner.pos - 1,
                                                       last_char)
        end

      when '['
        result = []
        first = true # TODO: can be replaced by checking result.empty? below?
        loop do
          @inline_scanner.read_next
          break if first && @inline_scanner.peek == ']'

          first = false
          result << parse_any
          break unless @inline_scanner.peek == ','
        end
        if @inline_scanner.empty?
          raise Errors::ParseInlineNoClosingDelimiterError.new(@inline_scanner.line,
                                                               @inline_scanner.pos)
        end
        last_char = @inline_scanner.read_next

        if last_char != ']'
          if result[-1] == ''
            raise Errors::ParseInlineMissingValueError.new(@inline_scanner.line,
                                                           @inline_scanner.pos - 1)
          end

          raise Errors::ParseInlineListSyntaxError.new(@inline_scanner.line, @inline_scanner.pos - 1, last_char)
        end
      else # Inline string
        inline_string = []
        until @inline_scanner.empty? || ['{', '}', '[', ']', ','].include?(@inline_scanner.peek)
          inline_string << @inline_scanner.read_next
        end
        result = inline_string.join.rstrip # Trim trailing whitespaces that lead up to next break point.
      end
      # Trim trailing whitespaces
      @inline_scanner.read_next while !@inline_scanner.empty? && [' ', "\t"].include?(@inline_scanner.peek)
      result
    end
  end
  private_constant :InlineParser
end
