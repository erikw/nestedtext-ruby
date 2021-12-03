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
                     # TODO continue here; detect :key_item properly
                     Line.new(linestr, :key_item, @io.lineno)
                   end
    end

    class Line
      # Reference: https://nestedtext.org/en/latest/file_format.html
      ALLOWED_LINE_TYPES = %i[comment blank list_item dictionary_item string_item key_item inline]

      attr_reader :type

      def initialize(line_content, type, lineno)
        @line_content = line_content
        @type = type
        @lineno = lineno

        # TODO: unit test this
        raise Errors::LineTypeUnknown, type unless ALLOWED_LINE_TYPES.include?(@type)
      end
    end
  end
end
