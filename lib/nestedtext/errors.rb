# frozen_string_literal: true

require "nestedtext/constants"

# TODO: extend IOError, EncodingError?
# TODO move errors to be in respective class who raise them?
# TODO attach column + read line and print out fancy arrow pointing at location where error was detected, similar to ntpy?
module NestedText
  # Top level Error for clients to rescue.
  class Error < StandardError; end

  module Errors
    class ParseError < Error
      attr_reader :lineno, :colno, :message_raw

      def initialize(line, colno, message)
        @lineno = line.lineno - 1  # TODO: official test seems to have 0-based line counting?
        @colno = colno || 0
        @message_raw = message

        colstr = colno.nil? ? "" : ", #{colno}"
        prefix = "#{lineno}#{colstr}: "
        super(prefix + message)
      end
    end

    class LineScannerIsEmpty < Error
      def initialize = super("There is no more input to consume. You should have checked this with #empty? before calling.")
    end

    class InlineScannerIsEmpty < Error
      def initialize = super("There is no more input to consume. You should have checked this with #empty? before calling.")
    end

    class LineTagUnknown < ParseError
      def initialize(line, tag) = super(line, nil, "The Line tag #{tag} is not among the allowed ones #{Line::ALLOWED_LINE_TAGS}")
    end

    class LineTagNotDetected < ParseError
      def initialize(line) = super(line, nil, "The type tag for the line could not be detected, using wrong syntax?")
    end

    class ListItemNoValue < ParseError
      def initialize(line) = super(line, nil, "A list item must have a value.")
    end

    class DictItemNoValue < ParseError
      def initialize(line) = super(line, nil, "A dict item must have a value.")
    end

    class MultilineKeyNoValue < ParseError
      def initialize(line) = super(line, nil, "A multiline key needs to have an indented value after it starting on the row after the key.")
    end

    class InlineDictSyntaxError < ParseError
      def initialize(line) = super(line, nil, "Inline dict could not be parsed.")
    end

    class InlineDictKeySyntaxError < ParseError
      def initialize(line) = super(line, nil, "Inline dict key could not be parsed.")
    end

    class InlineListSyntaxError < ParseError
      def initialize(line) = super(line, nil, "Inline list could not be parsed.")
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

    class InvalidIndentation < ParseError
      def initialize(line, ind_exp, ind_act) = super(line, nil, "The indentation of the current line is not valid. Expected indentation of #{ind_exp} but was #{ind_act}.")
    end

    class LineTypeNotExpected < ParseError
      def initialize(line, type_exps, type_act) = super(line, nil, "The current line was detected to be #{type_act}, but we expected to see any of [#{type_exps.join(", ")}] here.")
    end
  end
end
