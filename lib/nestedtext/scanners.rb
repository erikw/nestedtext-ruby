# frozen_string_literal: true

require "nestedtext/errors"

module NestedText
  class LineScanner
    # TODO: input should IO or StringIO
    # Need to set IO.autoclose=(true)?
    #
    def initialize(io)
      @io = io
      @next_line = nil
      prepare_next_line
    end

    def empty?
      @next_line.nil?
    end

    def next
      raise Errors::LineScannerIsEmpty if empty?

      line = @next_line
      prepare_next_line
      line
    end

    private

    def prepare_next_line
      linestr = @io.gets&.chomp
      @next_line = if linestr.nil?
                     nil
                   else
                     # linestr.chomp!
                     Line.new(linestr, @io.lineno)
                   end
    end

    class Line
      # Reference: https://nestedtext.org/en/latest/file_format.html
      # :comment            # a comment
      # :blank
      # :list_item         -item
      # :dict_item   key: value (or value on next line)
      # :string_item       > a string
      # :key_item          : key on a line
      # inline_dict        {key1: value1, key2: value2}
      # inline_list        [value1, value2]
      ALLOWED_LINE_TAGS = %i[comment blank list_item dict_item string_item key_item inline_dict inline_list]

      attr_reader :tag, :line_content
      attr_accessor :key, :value

      def initialize(line_content, lineno)
        @line_content = line_content
        @lineno = lineno
        @tag = nil
        # TODO: key value should be stored in some parse_attribs dict?
        @key = nil
        @value = nil
      end

      def length
        @line_content.length
      end

      def [](index)
        @line_content[index]
      end

      def tag=(tag)
        @tag = tag
        # TODO: unit test this
        raise Errors::LineTagUnknown, type unless ALLOWED_LINE_TAGS.include?(@tag)
      end

      def to_s
        "[##{@lineno}] #{@line_content}"
      end
    end
  end
end
