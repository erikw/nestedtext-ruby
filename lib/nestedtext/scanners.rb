# frozen_string_literal: true

require "nestedtext/errors"

module NestedText
  class LineScanner
    def initialize(io)
      @io = io
      @next_line = nil
      prepare_next_line
    end

    def empty?
      @next_line.nil?
    end

    def read_next
      raise Errors::LineScannerIsEmpty if empty?

      line = @next_line
      prepare_next_line
      line
    end

    def peek
      @next_line
    end

    def next_peek
      @next_line
    end

    private

    def prepare_next_line
      loop do
        linestr = @io.gets&.chomp
        @next_line = linestr.nil? ? nil : Line.new(linestr, @io.lineno)
        break if @next_line.nil? || !%i[blank comment].include?(@next_line.tag)
      end
    end
  end

  class Line
    # Reference: https://nestedtext.org/en/latest/file_format.html
    # :comment            # a comment
    # :blank
    # :list_item         - item
    # :dict_item          key: value (or value on next line)
    # :string_item       > a string
    # :key_item          : key on a line
    # inline_dict        {key1: value1, key2: value2}
    # inline_list        [value1, value2]
    ALLOWED_LINE_TAGS = %i[comment blank list_item dict_item string_item key_item inline_dict inline_list]

    attr_reader :tag, :line_content, :indentation, :attribs

    def initialize(line_content, lineno)
      @line_content = line_content
      @lineno = lineno
      @attribs = Hash.new(nil)
      @tag = nil
      @indentation = 0
      _detect_line_tag_and_indentation
    end

    def length
      @line_content.length
    end

    def [](index)
      @line_content[index]
    end

    def tag=(tag)
      @tag = tag
      raise Errors::LineTagUnknown, type unless ALLOWED_LINE_TAGS.include?(@tag)
    end

    def to_s
      "[##{@lineno}] #{" " * @indentation}#{@line_content}"
    end

    private

    def _detect_line_tag_and_indentation
      @indentation += 1 while @indentation < @line_content.length && @line_content[@indentation] == " "
      @line_content = @line_content[@indentation..]

      if @line_content.length == 0
        @tag = :blank
      elsif @line_content[0] == "#"
        @tag = :comment
      elsif /^:(?: |$)/.match @line_content
        @tag = :key_item
      elsif /-(?: |$)/.match @line_content
        @tag = :list_item
      elsif />(?: |$)/.match @line_content
        @tag = :string_item
      elsif @line_content[0] == "{"
        @tag = :inline_dict
      elsif @line_content[0] == "["
        @tag = :inline_list
      elsif /^(?<key>.*?) *:(?: (?<value>.*))?$/.match @line_content
        # TODO: this regex must be extracted and unit tested. What are the constraints of the value?
        @tag = :dict_item
        @attribs["key"] = Regexp.last_match(:key)
        @attribs["value"] = Regexp.last_match(:value)
      else
        raise Errors::LineTagNotDetected, @line_content
      end
    end
  end
end
