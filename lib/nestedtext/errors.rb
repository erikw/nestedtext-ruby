# frozen_string_literal: true

require "word_wrap"
require "word_wrap/core_ext"

require "nestedtext/constants"

module NestedText
  # TODO: migrate these ones to ParseError (if possible)
  class ErrorTODODeprecated < StandardError; end

  # TODO: Does dump() need separate error hierarchy? If so, create top level Error that both inherit. And move Parse/DumpError down to Errors module.
  class ParseError < StandardError
    # Top level ParseError for clients to rescue.
    attr_reader :lineno, :colno, :message_raw

    def initialize(line, colno, message)
      # Note, both line and column number are 0-indexed.
      # But for human display we make them 1-indexed.
      @lineno = line.lineno
      @colno = colno
      @message_raw = message
      super(pretty_message(line))
    end

    private

    def pretty_message(line)
      lineno_disp = @lineno + 1
      colno_disp = @colno + 1
      prefix = "\nParse ParseError (line #{lineno_disp}, column #{colno_disp}): "

      last_lines = ""
      # From one line to another, we can at most have 1 digits length difference.
      digits = lineno_disp.to_s.length
      unless line.prev.nil?
        lline_indent = " " * line.prev.indentation
        prev_lineno_disp = line.prev.lineno + 1
        last_lines += "\n\t#{prev_lineno_disp.to_s.rjust(digits)}|#{lline_indent}#{line.prev.content}"
      end
      line_indent = " " * line.indentation
      last_lines += "\n\t#{lineno_disp}|#{line_indent}#{line.content}"

      marker_indent = colno_disp + digits # +1 for the "|"
      marker = "\n\t" + " " * marker_indent + "^"

      prefix + @message_raw + last_lines + marker
    end
  end

  module Errors
    class LineScannerIsEmpty < ErrorTODODeprecated
      def initialize
        super("There is no more input to consume. You should have checked this with #empty? before calling.")
      end
    end

    class InlineScannerIsEmpty < ErrorTODODeprecated
      def initialize
        super("There is no more input to consume. You should have checked this with #empty? before calling.")
      end
    end

    class LineTagUnknown < ParseError
      def initialize(line, tag)
        # TODO: should not pass colno=0 probably??
        super(line, 0, "The Line tag #{tag} is not among the allowed ones #{Line::ALLOWED_LINE_TAGS}")
      end
    end

    class LineTagNotDetected < ParseError
      def initialize(line)
        super(line, line.indentation, "unrecognized line.")
      end
    end

    class ListItemNoValue < ParseError
      def initialize(line)
        # TODO: should this pass colno=0?
        super(line, 0, "A list item must have a value.")
      end
    end

    class DictItemNoValue < ParseError
      def initialize(line)
        # TODO: should this pass colno=0?
        super(line, 0, "A dict item must have a value.")
      end
    end

    class MultilineKeyNoValue < ParseError
      def initialize(line)
        super(line, line.indentation, "multiline key requires a value.")
      end
    end

    class InlineDictSyntaxError < ParseError
      def initialize(line)
        # TODO: should this pass colno=0?
        super(line, 0, "Inline dict could not be parsed.")
      end
    end

    class InlineDictKeySyntaxError < ParseError
      def initialize(line, colno, wrong_char)
        super(line, line.indentation + colno, "expected ‘:’, found ‘#{wrong_char}’.")
      end
    end

    class InlineListSyntaxError < ParseError
      def initialize(line)
        # TODO: should this pass colno=0?
        super(line, 0, "Inline list could not be parsed.")
      end
    end

    class InlineNoClosingDelimiter < ParseError
      def initialize(line, colno)
        super(line, line.indentation + colno, "line ended without closing delimiter.")
      end
    end

    class InlineExtraCharactersAfterDelimiter < ParseError
      def initialize(line, colno, extra_chars)
        character_str = extra_chars.length > 1 ? "characters" : "character"
        super(line, line.indentation + colno, "extra #{character_str} after closing delimiter: ‘#{extra_chars}’.")
      end
    end

    class UnsupportedTopLevelTypeError < ErrorTODODeprecated
      def initialize(type_class)
        super("The given top level type #{type_class&.name} is unsupported. Chose between #{TOP_LEVEL_TYPES.join(", ")}.")
      end
    end

    class WrongInputTypeError < ErrorTODODeprecated
      def initialize(class_exps, class_act)
        super("The given input type #{class_act.class.name} is unsupported. Expected to be of types #{class_exps.map(&:name).join(", ")}")
      end
    end

    class TopLevelTypeMismatchParsedType < ErrorTODODeprecated
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
        # TODO: should this pass colno=0?
        super(line, 0, "The current line was detected to be #{type_act}, but we expected to see any of [#{type_exps.join(", ")}] here.")
      end
    end

    class LineTypeExpectedDictItem < ParseError
      def initialize(line)
        # TODO: should this pass colno=0?
        super(line, 0, "expected dictionary item.")
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

    class DictDuplicateKey < ParseError
      def initialize(line)
        super(line, line.indentation, "duplicate key: #{line.attribs["key"]}.")
      end
    end
  end
end
