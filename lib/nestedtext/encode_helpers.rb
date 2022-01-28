# frozen_string_literal: true

require 'nestedtext/dumper'

module NestedText
  # A mixin for Custom Classes to get the to_nt shortcut.
  module ToNTMixin
    # Encode this object to a NestedText string.
    #
    # This method takes the same named arguments as {NestedText.dump}.
    def to_nt(**kwargs)
      NestedText.dump(self, strict: false, **kwargs)
    end
  end
end
