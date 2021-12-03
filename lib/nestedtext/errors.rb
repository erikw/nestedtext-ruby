# frozen_string_literal: true

# TODO: extend IOError, EncodingError?
module NestedText
  module Errors
    class LineTypeUnknown < StandardError
      def initialize(type) = super("The Line type #{type} is not among the allowed ones #{Line::ALLOWED_LINE_TYPES}")
    end

    class LineScannerIsEmpty < StandardError
      def initialize = super("There is no more input to consume. You should have checked this with #empty? before calling.")
    end
  end
end
