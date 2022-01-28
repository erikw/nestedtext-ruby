# frozen_string_literal: true

module NestedText
  # Top level error to rescue on.
  #
  # Error is a subclass of StandardError and behaves as expected e.g. #message.
  class Error < StandardError
    private_class_method :new
  end
end
