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
        raise NotImplementedError
      when :inline_list
        parse_inline_list
      else
        raise "Unexpected line tag! #{@line_scanner.peek.tag}"
      end
    end

    def parse_list_item(indentation)
      result = []
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        cur_line = @line_scanner.read_next
        raise Errors::InvalidIndentation.new(indentation, cur_line.indentation) if cur_line.indentation != indentation
        raise Errors::LineTypeNotExpected.new(%i[list_item], cur_line.tag) unless cur_line.tag == :list_item

        value = cur_line.attribs["value"]
        if value.nil?
          if !@line_scanner.peek.nil? && @line_scanner.peek.indentation > indentation
            value = parse_any(@line_scanner.peek.indentation)
          elsif @line_scanner.peek.nil? || @line_scanner.peek.tag == :list_item
            value = ""
          else
            raise "List item value could not be found"
          end
        end

        result <<  value
      end
      result
    end

    def parse_dict_item(indentation)
      result = {}
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        cur_line = @line_scanner.read_next
        raise Errors::InvalidIndentation.new(indentation, cur_line.indentation) if cur_line.indentation != indentation

        value = nil
        key = nil
        if cur_line.tag == :dict_item
          key = cur_line.attribs["key"]
          value = cur_line.attribs["value"]
          if value.nil?
            if !@line_scanner.peek.nil? && @line_scanner.peek.indentation > indentation
              value = parse_any(@line_scanner.peek.indentation)
            elsif @line_scanner.peek.nil? || @line_scanner.peek.tag == :dict_item
              value = ""
            else
              raise "Dict item value could not be found"
            end
          end
        elsif cur_line.tag == :key_item
          key = cur_line.attribs["key"]
          while @line_scanner.peek&.tag == :key_item && @line_scanner.peek.indentation == indentation
            cur_line = @line_scanner.read_next
            key += "\n" + cur_line.attribs["key"] # TODO: what is the original linebreak was e.g. \r\n ?
          end
          exp_types = %i[dict_item key_item list_item string_item]
          if @line_scanner.peek.nil?
            value = ""
          else
            unless exp_types.member?(@line_scanner.peek&.tag)
              raise Errors::LineTypeNotExpected.new(exp_types, cur_line.tag)
            end

            value = parse_any(@line_scanner.peek&.indentation)
          end
        else
          raise Errors::LineTypeNotExpected.new(%i[dict_item key_item], cur_line.tag)
        end
        result[key] = value
      end
      result
    end

    def parse_string_item(indentation)
      result = []
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        cur_line = @line_scanner.read_next
        raise Errors::InvalidIndentation.new(indentation, cur_line.indentation) if cur_line.indentation != indentation
        raise Errors::LineTypeNotExpected.new(%i[string_item], cur_line.tag) unless cur_line.tag == :string_item

        value = cur_line.attribs["value"]
        if value.nil?
          if @line_scanner.peek.nil? || @line_scanner.peek.tag == :string_item
            value = ""
          else
            raise "String item value could not be found"
          end
        end

        result << value
      end
      result.join("\n")
    end

    def parse_inline_key
      key = []
      key << @inline_scanner.read_next until @inline_scanner.empty? || @inline_scanner.peek == ":"
      key.join.strip
    end

    def parse_inline
      return nil if @inline_scanner.peek.nil?

      result = nil
      @inline_scanner.read_next while !@inline_scanner.empty? && @inline_scanner.peek == " "
      case @inline_scanner.peek
      when "{"
        result = {}
        loop do
          @inline_scanner.read_next
          key = parse_inline_key
          value = parse_inline
          result[key] = value
          break unless @inline_scanner.peek == ","
        end
        last_char = @inline_scanner.read_next
        raise "Better syntax error here" unless last_char == "}"

        @inline_scanner.read_next
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
        last_char = @inline_scanner.read_next
        raise Errors::InlineListSyntaxError unless last_char == "]"
      else # inline string
        # TODO: if we're inside dict, string can't have colon, but already handled as we we have parse_inline_key?
        inline_string = []
        until @inline_scanner.empty? || ["{", "}", "[", "]", ","].include?(@inline_scanner.peek)
          inline_string << @inline_scanner.read_next
        end
        result = inline_string.join.rstrip
      end
      result
    end

    def parse_inline_list
      @inline_scanner = InlineScanner.new(@line_scanner.read_next.line_content)
      result = parse_inline
      raise "Better errors please!" unless result.is_a? Array

      result
    end
  end
end
