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

# TODO: add encoding of more Ruby native classes like Integer, Float etc plus commons like Set,....?,
#     that are not covered in NestedText language.
# Or leave this to a schema validator 3rd party plugin maybe? And replace my custom class decoding (and also encoding?)?
# Or both: add encoding/decoding of more native classes, and allow decoding + applying a schema with 3rd party.
# Or encourage using Marshal from core?
