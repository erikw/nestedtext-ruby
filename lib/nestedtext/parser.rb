# frozen_string_literal: true

require "stringio"

require "nestedtext/errors"
require "nestedtext/scanners"
require "nestedtext/helpers"

module NestedText
  class Parser
    # Doc: caller is responsible for closing IO after done with Parser.
    def initialize(io, top_class)
      _assert_valid_input_type io
      NestedText.assert_valid_top_level_type(top_class)
      @top_class = top_class
      @line_scanner = LineScanner.new(io)
    end

    def parse
      result = _parse_any(0)
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

    def _assert_valid_input_type(input)
      unless input.nil? || input.is_a?(IO) || input.is_a?(StringIO)
        raise Errors::WrongInputTypeError.new([IO, StringIO], input)
      end
    end

    def _parse_any(indentation)
      return nil if @line_scanner.peek.nil?

      case @line_scanner.peek.tag # TODO: Use Null Pattern instead with a EndOfInput tag?
      when :list_item
        _parse_list_item(indentation)
      when :dict_item, :key_item
        _parse_dict_item(indentation)
      when :string_item
        _parse_string_item(indentation)
      when :inline_dict
        raise NotImplementedError
      when :inline_list
        raise NotImplementedError
      else
        raise "Unexpected line tag! #{@line_scanner.peek.tag}"
      end
    end

    def _parse_list_item(indentation)
      result = []
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        cur_line = @line_scanner.read_next
        raise Errors::InvalidIndentation.new(indentation, cur_line.indentation) if cur_line.indentation != indentation
        raise Errors::LineTypeNotExpected.new(%i[list_item], cur_line.tag) unless cur_line.tag == :list_item

        value = cur_line.attribs["value"]
        if value.nil?
          if !@line_scanner.peek.nil? && @line_scanner.peek.indentation > indentation
            value = _parse_any(@line_scanner.peek.indentation)
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

    def _parse_dict_item(indentation)
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
              value = _parse_any(@line_scanner.peek.indentation)
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
            key += "\n" + cur_line.attribs["key"]  # TODO: what is the original linebreak was e.g. \r\n ?
          end
          exp_types = %i[dict_item key_item list_item string_item]
          if @line_scanner.peek.nil?
            value = ""
          else
            unless exp_types.member?(@line_scanner.peek&.tag)
              raise Errors::LineTypeNotExpected.new(exp_types, cur_line.tag)
            end

            value = _parse_any(@line_scanner.peek&.indentation)
          end
        else
          raise Errors::LineTypeNotExpected.new(%i[dict_item key_item], cur_line.tag)
        end
        result[key] = value
      end
      result
    end

    def _parse_string_item(indentation)
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
  end
end
