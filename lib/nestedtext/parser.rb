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
      # TODO: why do we need to prefix NestedText. here, but not when used in decode.rb?
      NestedText.assert_valid_top_level_type top_class
      @top_class = top_class
      @line_scanner = LineScanner.new(io)
    end

    def parse
      result = _parse_any(0)
      case @top_class.object_id
      when Object.object_id
        # raise "better error here" unless result.instance_of?(Object)
        # TODO test that result is Hash, Array, String, or nil

      when Hash.object_id
        result = {} if result.nil?
        raise Errors::TopLevelTypeMismatchParsedType.new(@top_class, result) unless result.instance_of?(Hash)
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
        raise NotImplementedError
      when :dict_item
        _parse_dict_item(indentation)
      when :string_item
        raise NotImplementedError
      when :key_item
        raise NotImplementedError
      when :inline
        raise NotImplementedError
      else
        raise "Unexpected line tag!"
      end
    end

    def _parse_dict_item(indentation)
      result = {}
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        cur_line = @line_scanner.read_next
        raise Errors::InvalidIndentation.new(indentation, cur_line.indentation) if cur_line.indentation != indentation

        raise Errors::LineTypeNotExpected.new(:dict_item, cur_line.tag) if cur_line.tag != :dict_item

        value = cur_line.attribs["value"]
        if value.nil?
          if !@line_scanner.peek.nil? && @line_scanner.peek.indentation > indentation
            value = _parse_any(@line_scanner.peek&.indentation)
          elsif @line_scanner.peek.nil? || @line_scanner.peek.tag == :dict_item
            value = ""
          else
            raise "Dict item value could not be found"
          end
        end
        result[cur_line.attribs["key"]] = value
      end
      result
    end
  end
end
