# frozen_string_literal: true

require 'stringio'

require 'nestedtext/errors_internal'
require 'nestedtext/scanners'
require 'nestedtext/constants'
require 'nestedtext/inline_parser'

module NestedText
  # A LL(1) recursive descent parser for NT.
  class Parser
    def self.assert_valid_top_level_type(top_class)
      unless !top_class.nil? && top_class.is_a?(Class) && TOP_LEVEL_TYPES.map(&:object_id).include?(top_class.object_id)
        raise Errors::UnsupportedTopLevelTypeError, top_class
      end
    end

    def initialize(io, top_class, strict: false)
      assert_valid_input_type io
      Parser.assert_valid_top_level_type(top_class)
      @top_class = top_class
      @strict = strict
      @line_scanner = LineScanner.new(io)
    end

    def parse
      result = parse_any(0)
      case @top_class.object_id
      when Object.object_id
        raise Errors::AssertionError, 'Parsed result is of unexpected type.' if
        !result.nil? && ![Hash, Array, String].include?(result.class) && @strict
      when Hash.object_id
        result = {} if result.nil?
        raise Errors::TopLevelTypeMismatchParsedTypeError.new(@top_class, result) unless result.instance_of?(Hash)
      when Array.object_id
        result = [] if result.nil?
        raise Errors::TopLevelTypeMismatchParsedTypeError.new(@top_class, result) unless result.instance_of?(Array)
      when String.object_id
        result = '' if result.nil?
        raise Errors::TopLevelTypeMismatchParsedTypeError.new(@top_class, result) unless result.instance_of?(String)
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
        raise Errors::AssertionError, "Unexpected line tag! #{@line_scanner.peek.tag}"
      end
    end

    def parse_list_item(indentation)
      result = []
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        line = @line_scanner.read_next

        Errors.raise_unrecognized_line(line) if line.tag == :unrecognized
        raise Errors::ParseLineTypeExpectedListItemError, line unless line.tag == :list_item
        raise Errors::ParseInvalidIndentationError.new(line, indentation) if line.indentation != indentation

        value = line.attribs['value']
        if value.nil?
          if !@line_scanner.peek.nil? && @line_scanner.peek.indentation > indentation
            value = parse_any(@line_scanner.peek.indentation)
          elsif @line_scanner.peek.nil? || @line_scanner.peek.tag == :list_item
            value = ''
          end
        end

        result << value
      end
      result
    end

    def parse_key_item(indentation, line)
      key = line.attribs['key']
      value = nil
      while @line_scanner.peek&.tag == :key_item && @line_scanner.peek.indentation == indentation
        line = @line_scanner.read_next
        key += "\n#{line.attribs['key']}"
      end
      exp_types = %i[dict_item key_item list_item string_item]
      if @line_scanner.peek.nil?
        value = ''
      else
        unless exp_types.member?(@line_scanner.peek.tag)
          raise Errors::ParseLineTypeNotExpectedError.new(line, exp_types, line.tag)
        end

        unless @line_scanner.peek.indentation > indentation
          raise Errors::ParseMultilineKeyNoValueError,
                line
        end

        value = parse_any(@line_scanner.peek.indentation)
      end
      [key, value]
    end

    def parse_dict_item(indentation)
      result = {}
      first_line = nil
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        line = @line_scanner.read_next
        first_line = line if first_line.nil?
        Errors.raise_unrecognized_line(line) if line.tag == :unrecognized
        raise Errors::ParseInvalidIndentationError.new(line, indentation) if line.indentation != indentation
        raise Errors::ParseLineTypeExpectedDictItemError, line unless %i[dict_item key_item].include? line.tag

        key = nil
        value = nil
        if line.tag == :dict_item
          key = line.attribs['key']
          value = line.attribs['value']
          if value.nil?
            value = ''
            if !@line_scanner.peek.nil? && @line_scanner.peek.indentation > indentation
              value = parse_any(@line_scanner.peek.indentation)
            end
          end
        else # :key_item
          key, value = parse_key_item(indentation, line)
        end
        raise Errors::ParseDictDuplicateKeyError, line if result.key? key

        result[key] = value
      end

      # Custom class decoding.
      if !@strict && result.length == 2 && result.key?(CUSTOM_CLASS_KEY)
        class_name = result[CUSTOM_CLASS_KEY]
        begin
          clazz = class_name == 'nil' ? NilClass : Object.const_get(class_name, false)
        rescue NameError
          raise Errors::ParseCustomClassNotFoundError.new(first_line, class_name)
        end
        unless clazz.respond_to? :nt_create
          raise Errors::ParseCustomClassNoCreateMethodError.new(first_line, class_name)
        end

        result = clazz.nt_create(result['data'])
      end

      result
    end

    def parse_string_item(indentation)
      result = []
      while !@line_scanner.peek.nil? && @line_scanner.peek.indentation >= indentation
        line = @line_scanner.read_next
        raise Errors::ParseInvalidIndentationError.new(line, indentation) if line.indentation != indentation
        raise Errors::ParseLineTypeNotExpectedError.new(line, %i[string_item], line.tag) unless line.tag == :string_item

        value = line.attribs['value']
        result << value
      end
      result.join("\n")
    end

    def parse_inline_dict
      result = InlineParser.new(@line_scanner.read_next).parse
      unless result.is_a? Hash
        raise Errors::AssertionError,
              "Expected inline value to be Hash but is #{result.class.name}"
      end

      result
    end

    def parse_inline_list
      result = InlineParser.new(@line_scanner.read_next).parse
      unless result.is_a? Array
        raise Errors::AssertionError,
              "Expected inline value to be Array but is #{result.class.name}"
      end

      result
    end
  end
  private_constant :Parser
end
