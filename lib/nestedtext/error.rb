module NestedText
  # Top level error for users to rescue on.
  class Error < StandardError
    private_class_method :new
  end
end
