# frozen_string_literal: true

require 'word_wrap'
require 'word_wrap/core_ext'

require 'nestedtext/constants'
require 'nestedtext/error'

module NestedText
  module Errors
    class InternalError < Error
      public_class_method :new # Prevent users from instantiating.
    end

    class ParseError < InternalError
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

        last_lines = ''
        # From one line to another, we can at most have 1 digits length difference.
        digits = lineno_disp.to_s.length
        unless line.prev.nil?
          lline_indent = ' ' * line.prev.indentation
          prev_lineno_disp = line.prev.lineno + 1
          last_lines += "\n\t#{prev_lineno_disp.to_s.rjust(digits)}│#{lline_indent}#{line.prev.content}"
        end
        line_indent = ' ' * line.indentation
        last_lines += "\n\t#{lineno_disp}│#{line_indent}#{line.content}"

        marker_indent = colno_disp + digits # +1 for the "|"
        marker = "\n\t#{' ' * marker_indent}^"

        prefix + @message_raw + last_lines + marker
      end
    end

    class ParseLineTagUnknownError < ParseError
      def initialize(line, tag)
        super(line, line.indentation, "The Line tag #{tag} is not among the allowed ones #{Line::ALLOWED_LINE_TAGS}")
      end
    end

    class ParseLineTagNotDetectedError < ParseError
      def initialize(line)
        super(line, line.indentation, 'unrecognized line.')
      end
    end

    class ParseLineTypeExpectedListItemError < ParseError
      def initialize(line)
        super(line, line.indentation, 'expected list item.')
      end
    end

    class ParseMultilineKeyNoValueError < ParseError
      def initialize(line)
        super(line, line.indentation, 'multiline key requires a value.')
      end
    end

    class ParseInlineDictSyntaxError < ParseError
      def initialize(line, colno, wrong_char)
        super(line, line.indentation + colno, "expected ‘,’ or ‘}’, found ‘#{wrong_char}’.")
      end
    end

    class ParseInlineDictKeySyntaxError < ParseError
      def initialize(line, colno, wrong_char)
        super(line, line.indentation + colno, "expected ‘:’, found ‘#{wrong_char}’.")
      end
    end

    class ParseInlineMissingValueError < ParseError
      def initialize(line, colno)
        super(line, line.indentation + colno, 'expected value.')
      end
    end

    class ParseInlineListSyntaxError < ParseError
      def initialize(line, colno, wrong_char)
        super(line, line.indentation + colno, "expected ‘,’ or ‘]’, found ‘#{wrong_char}’.")
      end
    end

    class ParseInlineNoClosingDelimiterError < ParseError
      def initialize(line, colno)
        super(line, line.indentation + colno, 'line ended without closing delimiter.')
      end
    end

    class ParseInlineExtraCharactersAfterDelimiterError < ParseError
      def initialize(line, colno, extra_chars)
        character_str = extra_chars.length > 1 ? 'characters' : 'character'
        super(line, line.indentation + colno, "extra #{character_str} after closing delimiter: ‘#{extra_chars}’.")
      end
    end

    class ParseInvalidIndentationError < ParseError
      def initialize(line, ind_exp)
        prev_line = line.prev
        message = if prev_line.nil? && ind_exp.zero?
                    'top-level content must start in column 1.'
                  elsif !prev_line.nil? &&
                        prev_line.attribs.key?('value') &&
                        prev_line.indentation < line.indentation &&
                        %i[dict_item list_item].member?(prev_line.tag)
                    'invalid indentation.'
                  elsif !prev_line.nil? && line.indentation < prev_line.indentation
                    # Can't use ind_exp here, because it's a difference if the previous line was further indented.
                    # See test_load_error_dict_10
                    'invalid indentation, partial dedent.'
                  else
                    'invalid indentation.'
                  end
        # Need to wrap like official tests. #wrap always add an extra \n we need to chop off.
        message_wrapped = message.wrap(70).chop
        super(line, ind_exp, message_wrapped)
      end
    end

    class ParseLineTypeNotExpectedError < ParseError
      def initialize(line, type_exps, type_act)
        super(line, line.indentation,
              "The current line was detected to be #{type_act}, "\
              "but we expected to see any of [#{type_exps.join(', ')}] here.")
      end
    end

    class ParseLineTypeExpectedDictItemError < ParseError
      def initialize(line)
        super(line, line.indentation, 'expected dictionary item.')
      end
    end

    class ParseInvalidIndentationCharError < ParseError
      def initialize(line)
        printable_char = line.content[0].dump.gsub(/"/, '')

        # Looking for non-breaking space is just to be compatible with official tests.
        explanation = ''
        if printable_char == '\\u00A0'
          printable_char = '\\xa0'
          explanation = ' (NO-BREAK SPACE)'
        end

        message = "invalid character in indentation: '#{printable_char}'#{explanation}."
        super(line, line.indentation, message)
      end
    end

    class ParseDictDuplicateKeyError < ParseError
      def initialize(line)
        super(line, line.indentation, "duplicate key: #{line.attribs['key']}.")
      end
    end

    class ParseCustomClassNotFoundError < ParseError
      def initialize(line, class_name)
        super(line, line.indentation,
              "Detected an encode custom class #{class_name} " \
              "however we can't find it, so it can't be deserialzied.")
      end
    end

    class ParseCustomClassNoCreateMethodError < ParseError
      def initialize(line, class_name)
        super(line, line.indentation,
              "Detected an encode custom class #{class_name} "\
              "but it does not have a #nt_create method, so it can't be deserialzied.")
      end
    end

    class AssertionError < InternalError; end

    class AssertionLineScannerIsEmptyError < AssertionError
      def initialize
        super('There is no more input to consume. You should have checked this with #empty? before calling.')
      end
    end

    class AssertionInlineScannerIsEmptyError < AssertionError
      def initialize
        super('There is no more input to consume. You should have checked this with #empty? before calling.')
      end
    end

    class DumpError < InternalError
      attr_reader :culprit

      def initialize(culprit, message)
        # Note, both line and column number are 0-indexed.
        # But for human display we make them 1-indexed.
        @culprit = culprit
        super(message)
      end
    end

    class DumpUnsupportedTypeError < DumpError
      def initialize(obj, culprit)
        # Needed to pass official test.
        class_name = obj.is_a?(Integer) ? 'int' : obj.class.name
        super(culprit, "unsupported type (#{class_name}).")
      end
    end

    class DumpCyclicReferencesDetectedError < DumpError
      def initialize(culprit)
        super(culprit, 'cyclic reference found: cannot be dumped.')
      end
    end

    class DumpHashKeyStrictStringError < DumpError
      def initialize(obj)
        super(obj, 'keys must be strings.')
      end
    end

    def self.raise_unrecognized_line(line)
      # [[:space:]] include all Unicode spaces e.g. non-breakable space which \s does not.
      raise ParseInvalidIndentationCharError, line if line.content.chr =~ /[[:space:]]/

      raise ParseLineTagNotDetectedError, line
    end

    class UnsupportedTopLevelTypeError < InternalError
      def initialize(type_class)
        super("The given top level type #{type_class&.name} is unsupported." \
              "Chose between #{TOP_LEVEL_TYPES.join(', ')}.")
      end
    end

    class WrongInputTypeError < InternalError
      def initialize(class_exps, class_act)
        super("The given input type #{class_act.class.name} is unsupported. " \
              "Expected to be of types #{class_exps.map(&:name).join(', ')}")
      end
    end

    class TopLevelTypeMismatchParsedTypeError < InternalError
      def initialize(class_exp, class_act)
        super("The requested top level class #{class_exp.name} " \
              "is not the same as the actual parsed top level class #{class_act}.")
      end
    end

    class DumpBadIOError < InternalError
      def initialize(io)
        super('When giving the io argument, it must be of type IO (respond to #write, #fsync).' \
              " Given: #{io.class.name}")
      end
    end

    class DumpFileBadPathError < InternalError
      def initialize(path)
        super("Must supply a string to a file path that can be written to. Given: #{path}")
      end
    end
  end
  private_constant :Errors
end
