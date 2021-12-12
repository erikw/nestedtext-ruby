# frozen_string_literal: true

require "stringio"

require "nestedtext/errors"
require "nestedtext/scanners"
require "nestedtext/helpers"

module NestedText
  class Parser
    def initialize(raw_input, top_class)
      _assert_valid_input_type raw_input
      @raw_input = raw_input
      # TODO: why do we need to prefix NestedText. here, but not when used in decode.rb?
      NestedText.assert_valid_top_level_type top_class
      @top_class = top_class
      @line_scanner = LineScanner.new(raw_input)
      @cur_line = nil
      @line_col = 0
    end

    def parse
      result = _parse_any
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

    PARSER_INPUT_TYPES = [IO, StringIO]

    def _assert_valid_input_type(input)
      # raise Errors::WrongInputTypeError.new([IO, StringIO], raw_input) unless [IO, StringIO].include? top.class
      unless input.nil? || PARSER_INPUT_TYPES.map(&:object_id).include?(input.class.object_id)
        raise Errors::WrongInputTypeError.new([IO, StringIO], input)
      end
    end

    def _parse_any
      case @line_scanner.peek&.tag # TODO: Use Null Pattern instead with a EndOfInput tag?
      when :list_item
        raise NotImplementedError
      when :dict_item
        _parse_dict_item
      when :string_item
        raise NotImplementedError
      when :key_item
        raise NotImplementedError
      when :inline
        raise NotImplementedError
      else
        nil # TODO: replace with null pattern?
      end
    end

    def _parse_dict_item
      result = {}
      # @cur_line = @line_scanner.next
      while @line_scanner.peek&.tag == :dict_item # just while hasNext pattern instead of peek?
        @cur_line = @line_scanner.next
        result[@cur_line.key] = (@cur_line.value || _parse_any)
      end
      result
    end
  end
end
