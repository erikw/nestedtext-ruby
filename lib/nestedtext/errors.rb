# frozen_string_literal: true

# TODO: extend IOError, EncodingError?
# TODO move errors to be in respective class who raise them?
module NestedText
  module Errors
    class LineTagUnknown < StandardError
      def initialize(tag) = super("The Line tag #{tag} is not among the allowed ones #{Line::ALLOWED_LINE_TAGS}")
    end

    class LineScannerIsEmpty < StandardError
      def initialize = super("There is no more input to consume. You should have checked this with #empty? before calling.")
    end

    class LineTagNotDetected < StandardError
      def initialize(line) = super("The type tag for the line could not be detected, using wrong syntax?\n#{line}")
    end
  end
end
