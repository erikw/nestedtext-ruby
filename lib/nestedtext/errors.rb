# frozen_string_literal: true

require "word_wrap"
require "word_wrap/core_ext"

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
        unless line.prev.nil?
          lline_indent = " " * line.prev.indentation
          last_lines += "\n\t#{line.prev.lineno.to_s.rjust(digits)}| #{lline_indent}#{line.prev.content}"
        end
        line_indent = " " * line.indentation
        last_lines += "\n\t#{line.lineno}| #{line_indent}#{line.content}"

        # +1 for the "\", but not for the space after so that col=0 will be before text starts.
        marker_indent = @colno + digits + 1
        marker = "\n\t" + " " * marker_indent + "^"

        prefix + @message_raw + last_lines + marker
      end
    end

    class LineScannerIsEmpty < Error
      def initialize
        super("There is no more input to consume. You should have checked this with #empty? before calling.")
      end
    end

    class InlineScannerIsEmpty < Error
      def initialize
        super("There is no more input to consume. You should have checked this with #empty? before calling.")
      end
    end

    class LineTagUnknown < ParseError
      def initialize(line, tag)
        super(line, 0, "The Line tag #{tag} is not among the allowed ones #{Line::ALLOWED_LINE_TAGS}")
      end
    end

    class LineTagNotDetected < ParseError
      def initialize(line)
        super(line, 0, "The type tag for the line could not be detected, using wrong syntax?")
      end
    end

    class ListItemNoValue < ParseError
      def initialize(line)
        super(line, 0, "A list item must have a value.")
      end
    end

    class DictItemNoValue < ParseError
      def initialize(line)
        super(line, 0, "A dict item must have a value.")
      end
    end

    class MultilineKeyNoValue < ParseError
      def initialize(line)
        super(line, 0, "A multiline key needs to have an indented value after it starting on the row after the key.")
      end
    end

    class InlineDictSyntaxError < ParseError
      def initialize(line)
        super(line, 0, "Inline dict could not be parsed.")
      end
    end

    class InlineDictKeySyntaxError < ParseError
      def initialize(line)
        super(line, 0, "Inline dict key could not be parsed.")
      end
    end

    class InlineListSyntaxError < ParseError
      def initialize(line)
        super(line, 0, "Inline list could not be parsed.")
      end
    end

    class UnsupportedTopLevelTypeError < Error
      def initialize(type_class)
        super("The given top level type #{type_class&.name} is unsupported. Chose between #{TOP_LEVEL_TYPES.join(", ")}.")
      end
    end

    class WrongInputTypeError < Error
      def initialize(class_exps, class_act)
        super("The given input type #{class_act.class.name} is unsupported. Expected to be of types #{class_exps.map(&:name).join(", ")}")
      end
    end

    class TopLevelTypeMismatchParsedType < Error
      def initialize(class_exp, class_act)
        super("The requested top level class #{class_exp.name} is not the same as the actual parsed top level class #{class_act&.class&.name || "nil"}.")
      end
    end

    class InvalidIndentation < ParseError
      def initialize(line, ind_exp)
        message = "The indentation of the current line is not valid. Expected indentation of #{ind_exp} but was #{line.indentation}"
        prev_line = line.prev
        if prev_line.nil? && ind_exp == 0
          message = "top-level content must start in column 1."
        elsif !prev_line.nil? &&
              prev_line.attribs.key?("value") &&
              prev_line.indentation < line.indentation &&
              %i[dict_item list_item].member?(prev_line.tag)
          cond = ""
          cond = ", which in this case consists only of whitespace" if prev_line.attribs["value"].strip.empty?
          message = "invalid indentation. " \
                    "An indent may only follow a dictionary or list item that " \
                    "does not already have a value#{cond}."
        elsif !prev_line.nil? && line.indentation < prev_line.indentation
          # Can't use ind_exp here, because it's a difference if the previous line was further indented. See test_load_error_dict_10
          message = "invalid indentation, partial dedent."
        end
        # Need to wrap like official tests. #wrap always add an extra \n we need to chop off.
        message_wrapped = message.wrap(70).chop
        super(line, ind_exp, message_wrapped)
      end
    end

    class LineTypeNotExpected < ParseError
      def initialize(line, type_exps, type_act)
        super(line, 0, "The current line was detected to be #{type_act}, but we expected to see any of [#{type_exps.join(", ")}] here.")
      end
    end

    class InvalidIndentationChar < ParseError
      def initialize(line)
        printable_char = line.content[0].dump.gsub(/"/, "")
        message = "invalid character in indentation: '#{printable_char}'."
        super(line, line.indentation, message)
      end
    end

    def self.raise_unrecognized_line(line)
      raise InvalidIndentationChar, line if line.content.chr =~ /\s/

      raise LineTagNotDetected, line
    end
  end
end
