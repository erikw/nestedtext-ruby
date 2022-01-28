# frozen_string_literal: true

require 'nestedtext/encode_helpers'

# Extended with the `#to_nt` method.
class String include NestedText::ToNTMixin; end

# Extended with the `#to_nt` method.
class Array include NestedText::ToNTMixin; end

# Extended with the `#to_nt` method.
class Hash include NestedText::ToNTMixin; end

# Extended with NestedText support.
class NilClass
  include NestedText::ToNTMixin

  # Adds support for encoding and decoding nil.
  def self.nt_create(_data) = nil

  # Adds support for encoding and decoding nil.
  def encode_nt_with() = ''
end
