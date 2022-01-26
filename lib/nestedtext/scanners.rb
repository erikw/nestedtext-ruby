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
      line.prev.prev = nil unless line.prev.nil? # GC: break the chain
      line
    end

    def peek
      @next_line
    end

    private

    def prepare_next_line
      line = nil
      loop do
        linestr = @io.gets&.chomp
        lineno = @io.lineno - 1 # Be 0-based
        line = linestr.nil? ? nil : Line.new(linestr, lineno, @next_line)
        break if line.nil? || !%i[blank comment].include?(line.tag)
      end
      @next_line = line
    end
  end
  private_constant :LineScanner

  class InlineScanner
    attr_reader :line, :pos

    def initialize(line)
      @line = line
      @pos = 0
    end

    def empty?
      @pos >= @line.content.length
    end

    def remaining
      @line.content[@pos..]
    end

    def read_next
      raise Errors::InlineScannerIsEmpty if empty?

      @pos += 1
      @line.content[@pos - 1]
    end

    def peek
      empty? ? nil : @line.content[@pos]
    end
  end
  private_constant :InlineScanner

  class Line
    # Reference: https://nestedtext.org/en/latest/file_format.html
    ALLOWED_LINE_TAGS = [
      :comment, # a comment
      :blank,
      :list_item,  # - item
      :dict_item,  # key: value (or value on next line)
      :string_item, # > a string, can continue next line
      :key_item,    # : key on a line
      :inline_dict, # {key1: value1, key2: value2}
      :inline_list, # [value1, value2]
      :unrecognized # could not be determined
    ]

    attr_accessor :prev
    attr_reader :tag, :content, :indentation, :attribs, :lineno

    def initialize(content, lineno, prev_line)
      @content = content
      @lineno = lineno
      @prev = prev_line
      @attribs = Hash.new(nil)
      @tag = nil
      @indentation = 0
      detect_line_tag_and_indentation
    end

    # def length
    # @content.length
    # end

    # def [](index)
    # @content[index]
    # end

    def tag=(tag)
      @tag = tag
      raise Errors::ParseLineTagUnknownError.new(self, tag) unless ALLOWED_LINE_TAGS.include?(@tag)
    end

    def to_s
      "[##{@lineno}] #{" " * @indentation}#{@content}"
    end

    private

    # TODO: this regex must  unit tested.
    PATTERN_DICT_ITEM = /^
             (?<key>[^\s].*?)   # Key must start with a non-whitespace character, and goes until first
              \s*:              # first optional space, or :-separator
              (?:               # Value part is optional
                \p{Space}       # Must have a space after :-separator
                (?<value>.*)    # Value is everything to the end of the line
              )?
              $/x

    def detect_line_tag_and_indentation
      @indentation += 1 while @indentation < @content.length && @content[@indentation] == " "
      @content = @content[@indentation..]

      if @content.length == 0
        self.tag = :blank
      elsif @content[0] == "#"
        self.tag = :comment
      elsif @content =~ /^:(?: |$)/
        self.tag = :key_item
        @attribs["key"] = @content[2..] || ""
      elsif @content =~ /^-(?: |$)/
        self.tag = :list_item
        @attribs["value"] = @content[2..]
      elsif @content =~ /^>(?: |$)/
        self.tag = :string_item
        @attribs["value"] = @content[2..] || ""
      elsif @content[0] == "{"
        self.tag = :inline_dict
      elsif @content[0] == "["
        # TODO: merge path of inline dict and list and just set :inline?
        self.tag = :inline_list
      elsif @content =~ PATTERN_DICT_ITEM
        self.tag = :dict_item
        @attribs["key"] = Regexp.last_match(:key)
        @attribs["value"] = Regexp.last_match(:value)
      else
        # Don't raise error here, as this line might not have been consumed yet,
        # thus could hide an error that we detect when parsing the previous line.
        self.tag = :unrecognized
      end
    end
  end
  private_constant :Line
end
