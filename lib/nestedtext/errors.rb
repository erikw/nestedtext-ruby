# frozen_string_literal: true

require "word_wrap"

require "nestedtext/constants"

module NestedText
  # Top level Error for clients to rescue.
  class Error < StandardError; end

  module Errors
    # TODO: should make this the top base error instead. ntpy has one error for everything. Should work to have linenumber for all errors. Maybe not dump errors though.
    class ParseError < Error
      attr_reader :lineno, :colno, :message_raw

      def initialize(line, colno, message)
        # Note, both line and column number is 1-indexed. column 0 means "nil"; the problem is on the whole line.
        @lineno = line.lineno
        @colno = colno
        @message_raw = message
        super(pretty_message(line))
      end

      private

      def pretty_message(line)
        prefix = "\nParse Error (line #{@lineno}, column #{@colno}): "

        last_lines = ""
        # From one line to another, we can at most have 1 digits length difference.
        digits = line.lineno.to_s.length
        unless line.prev_line.nil?
          lline_indent = " " * line.prev_line.indentation
          last_lines += "\n\t#{line.prev_line.lineno.to_s.rjust(digits)}| #{lline_indent}#{line.prev_line.line_content}"
        end
        line_indent = " " * line.indentation
        last_lines += "\n\t#{line.lineno}| #{line_indent}#{line.line_content}"

        # +1 for the "\", but not for the space after so that col=0 will be before text starts.
        marker_indent = @colno + digits + 1
        marker = "\n\t" + " " * marker_indent + "^"

        prefix + @message_raw + last_lines + marker
      end
    end

    class LineScannerIsEmpty < Error
      def initialize = super("There is no more input to consume. You should have checked this with #empty? before calling.")
    end

    class InlineScannerIsEmpty < Error
      def initialize = super("There is no more input to consume. You should have checked this with #empty? before calling.")
    end

    class LineTagUnknown < ParseError
      def initialize(line, tag) = super(line, 0, "The Line tag #{tag} is not among the allowed ones #{Line::ALLOWED_LINE_TAGS}")
    end

    class LineTagNotDetected < ParseError
      def initialize(line) = super(line, 0, "The type tag for the line could not be detected, using wrong syntax?")
    end

    class ListItemNoValue < ParseError
      def initialize(line) = super(line, 0, "A list item must have a value.")
    end

    class DictItemNoValue < ParseError
      def initialize(line) = super(line, 0, "A dict item must have a value.")
    end

    class MultilineKeyNoValue < ParseError
      def initialize(line) = super(line, 0, "A multiline key needs to have an indented value after it starting on the row after the key.")
    end

    class InlineDictSyntaxError < ParseError
      def initialize(line) = super(line, 0, "Inline dict could not be parsed.")
    end

    class InlineDictKeySyntaxError < ParseError
      def initialize(line) = super(line, 0, "Inline dict key could not be parsed.")
    end

    class InlineListSyntaxError < ParseError
      def initialize(line) = super(line, 0, "Inline list could not be parsed.")
    end

    class UnsupportedTopLevelTypeError < Error
      def initialize(type_class) = super("The given top level type #{type_class&.name} is unsupported. Chose between #{TOP_LEVEL_TYPES.join(", ")}.")
    end

    class WrongInputTypeError < Error
      def initialize(class_exps, class_act) = super("The given input type #{class_act.class.name} is unsupported. Expected to be of types #{class_exps.map(&:name).join(", ")}")
    end

    class TopLevelTypeMismatchParsedType < Error
      def initialize(class_exp, class_act) = super("The requested top level class #{class_exp.name} is not the same as the actual parsed top level class #{class_act&.class&.name || "nil"}.")
    end

    # TODO: s/prev_line/prev/
    class InvalidIndentation < ParseError
      def initialize(line, ind_exp, ind_act)
        message = "The indentation of the current line is not valid. Expected indentation of #{ind_exp} but was #{ind_act}."
        prev_line = line.prev_line
        if prev_line.nil? && ind_exp == 0
          message = "top-level content must start in column 1."
        elsif !prev_line.nil? &&
              prev_line.attribs.key?("value") &&
              prev_line.indentation < line.indentation &&
              %i[dict_item list_item].member?(prev_line.tag)
          cond = ""
          cond = ", which in this case consists only of whitespace" if prev_line.attribs["value"].strip.empty?
          message = "invalid indentation. An indent may only follow a dictionary or list item that does not already have a value#{cond}."
        end
        # Need to wrap like official tests. #ww always add an extra \n we need to chop off.
        message_wrapped = WordWrap.ww(message, 70).chop
        super(line, 0, message_wrapped)
      end
    end

    class LineTypeNotExpected < ParseError
      def initialize(line, type_exps, type_act) = super(line, 0, "The current line was detected to be #{type_act}, but we expected to see any of [#{type_exps.join(", ")}] here.")
    end
  end
end
