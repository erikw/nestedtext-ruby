# frozen_string_literal: true

require "stringio"

require "nestedtext/errors"
require "nestedtext/scanners"
require "nestedtext/helpers"

module NestedText
  class Parser
    # Doc: caller is responsible for closing IO after done with Parser.
    def initialize(io, top_class)
      assert_valid_input_type io
      NestedText.assert_valid_top_level_type(top_class)
      @top_class = top_class
      @line_scanner = LineScanner.new(io)
      @inline_scanner = nil
    end

    def parse
      result = parse_any(0)
      case @top_class.object_id
      when Object.object_id
        raise Errors::UnsupportedTopLevelTypeError, @top_class unless
                  result.nil? || [Hash, Array, String].include?(result.class)
      when Hash.object_id
        result = {} if result.nil?
        raise Errors::TopLevelTypeMismatchParsedType.new(@top_class, result) unless result.instance_of?(Hash)
      when Array.object_id
        result = [] if result.nil?
        raise Errors::TopLevelTypeMismatchParsedType.new(@top_class, result) unless result.instance_of?(Array)
      when String.object_id
        result = "" if result.nil?
        raise Errors::TopLevelTypeMismatchParsedType.new(@top_class, result) unless result.instance_of?(String)
      else
        raise Errors::UnsupportedTopLevelTypeError, @top_class
      end
      result
    end

    private

    def assert_valid_input_type(input)
      unless input.nil? || input.is_a?(IO) || input.is_a?(StringIO)
        raise Errors::WrongInputTypeError.new([IO, StringIO], input)
      end
    end

    def parse_any(indentation)
      return nil if @line_scanner.peek.nil?

      case @line_scanner.peek.tag # TODO: Use Null Pattern instead with a EndOfInput tag?
      when :list_item
        parse_list_item(indentation)
      when :dict_item, :key_item
        parse_dict_item(indentation)
      when :string_item
        parse_string_item(indentation)
      when :inline_dict
        parse_inline_dict
      when :inline_list
        parse_inline_list
      when :unrecognized
        Errors.raise_unrecognized_line(@line_scanner.peek)
      else
        raise "Unexpected line tag! #{@line_scanner.peek.tag}"
      end
    end

    def parse_list_item(indentation)
      result = []
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        line = @line_scanner.read_next

        Errors.raise_unrecognized_line(line) if line.tag == :unrecognized
        raise Errors::LineTypeExpectedListItem, line unless line.tag == :list_item
        raise Errors::InvalidIndentation.new(line, indentation) if line.indentation != indentation

        value = line.attribs["value"]
        if value.nil?
          if !@line_scanner.peek.nil? && @line_scanner.peek.indentation > indentation
            value = parse_any(@line_scanner.peek.indentation)
          elsif @line_scanner.peek.nil? || @line_scanner.peek.tag == :list_item
            value = ""
          else
            raise Errors::ListItemNoValue, line
          end
        end

        result << value
      end
      result
    end

    def parse_dict_item(indentation)
      result = {}
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        line = @line_scanner.read_next
        Errors.raise_unrecognized_line(line) if line.tag == :unrecognized
        raise Errors::InvalidIndentation.new(line, indentation) if line.indentation != indentation
        raise Errors::LineTypeExpectedDictItem, line unless %i[dict_item key_item].include? line.tag

        # Errors.raise_unrecognized_line(line) if line.tag == :unrecognized
        # raise Errors::LineTypeExpectedListItem, line unless line.tag == :list_item
        # raise Errors::InvalidIndentation.new(line, indentation) if line.indentation != indentation

        value = nil
        key = nil
        if line.tag == :dict_item
          key = line.attribs["key"]
          value = line.attribs["value"]
          if value.nil?
            value = ""
            if !@line_scanner.peek.nil? && @line_scanner.peek.indentation > indentation
              value = parse_any(@line_scanner.peek.indentation)
            end
          end
        else # :key_item
          key = line.attribs["key"]
          while @line_scanner.peek&.tag == :key_item && @line_scanner.peek.indentation == indentation
            line = @line_scanner.read_next
            key += "\n" + line.attribs["key"]
          end
          exp_types = %i[dict_item key_item list_item string_item]
          if @line_scanner.peek.nil?
            value = ""
          else
            unless exp_types.member?(@line_scanner.peek.tag)
              raise Errors::LineTypeNotExpected.new(line, exp_types, line.tag)
            end
            raise Errors::MultilineKeyNoValue, line unless @line_scanner.peek.indentation > indentation

            value = parse_any(@line_scanner.peek.indentation)
          end
        end
        raise Errors::DictDuplicateKey, line if result.key? key

        result[key] = value
      end
      result
    end

    def parse_string_item(indentation)
      result = []
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        line = @line_scanner.read_next
        raise Errors::InvalidIndentation.new(line, indentation) if line.indentation != indentation

        unless line.tag == :string_item
          raise Errors::LineTypeNotExpected.new(line, %i[string_item],
                                                line.tag)
        end

        value = line.attribs["value"]
        if value.nil?
          if @line_scanner.peek.nil? || @line_scanner.peek.tag == :string_item
            value = ""
          else
            raise "String item value could not be found at line: #{line}"
          end
        end

        result << value
      end
      result.join("\n")
    end

    def parse_inline_key
      key = []
      until @inline_scanner.empty? || [":", "{", "}", "[", "]", ","].include?(@inline_scanner.peek)
        key << @inline_scanner.read_next
      end
      if @inline_scanner.empty?
        raise Errors::InlineNoClosingDelimiter.new(@inline_scanner.line,
                                                   @inline_scanner.pos)
      end

      last_char = @inline_scanner.read_next
      if last_char == "}" && key.empty?
        raise Errors::InlineMissingValue.new(@inline_scanner.line, @inline_scanner.pos - 1)
      end
      unless last_char == ":"
        raise Errors::InlineDictKeySyntaxError.new(@inline_scanner.line, @inline_scanner.pos - 1, last_char)
      end

      key.join.strip
    end

    def parse_inline
      return nil if @inline_scanner.peek.nil?

      result = nil
      # Trim leading whitespaces
      @inline_scanner.read_next while !@inline_scanner.empty? && [" ", "\t"].include?(@inline_scanner.peek)
      case @inline_scanner.peek
      when "{"
        result = {}
        first = true
        loop do
          @inline_scanner.read_next
          break if first && @inline_scanner.peek == "}"

          first = false
          key = parse_inline_key
          value = parse_inline
          result[key] = value
          break unless @inline_scanner.peek == ","
        end
        last_char = @inline_scanner.read_next
        unless last_char == "}"
          raise Errors::InlineDictSyntaxError.new(@inline_scanner.line, @inline_scanner.pos - 1,
                                                  last_char)
        end

      when "["
        result = []
        first = true
        loop do
          @inline_scanner.read_next
          break if first && @inline_scanner.peek == "]"

          first = false
          result << parse_inline
          break unless @inline_scanner.peek == ","
        end
        if @inline_scanner.empty?
          raise Errors::InlineNoClosingDelimiter.new(@inline_scanner.line,
                                                     @inline_scanner.pos)
        end
        last_char = @inline_scanner.read_next

        if last_char != "]"
          if result[-1] == ""
            raise Errors::InlineMissingValue.new(@inline_scanner.line, @inline_scanner.pos - 1)
          else
            raise Errors::InlineListSyntaxError.new(@inline_scanner.line, @inline_scanner.pos - 1,
                                                    last_char)
          end
        end
      else # Inline string
        inline_string = []
        until @inline_scanner.empty? || ["{", "}", "[", "]", ","].include?(@inline_scanner.peek)
          inline_string << @inline_scanner.read_next
        end
        result = inline_string.join.rstrip # Trim trailing whitespaces that lead up to next break point.
      end
      # Trim trailing whitespaces
      @inline_scanner.read_next while !@inline_scanner.empty? && [" ", "\t"].include?(@inline_scanner.peek)
      result
    end

    def parse_inline_dict
      @inline_scanner = InlineScanner.new(@line_scanner.read_next)
      result = parse_inline
      unless @inline_scanner.empty?
        raise Errors::InlineExtraCharactersAfterDelimiter.new(@inline_scanner.line, @inline_scanner.pos,
                                                              @inline_scanner.remaining)
      end
      raise "Better errors please3" unless result.is_a? Hash

      result
    end

    def parse_inline_list
      @inline_scanner = InlineScanner.new(@line_scanner.read_next)
      result = parse_inline
      unless @inline_scanner.empty?
        raise Errors::InlineExtraCharactersAfterDelimiter.new(@inline_scanner.line, @inline_scanner.pos,
                                                              @inline_scanner.remaining)
      end
      raise "Better errors please1" unless result.is_a? Array

      result
    end
  end
end
