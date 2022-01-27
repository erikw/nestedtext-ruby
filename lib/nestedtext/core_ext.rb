require "nestedtext/encode_helpers"

# Extension of Ruby core types with the NestedText::NTEncodeMixin.
#
# TODO: add encoding of more Ruby native classes like Integer, Float etc plus commons like Set,....? Not covered in NestedText language.
# Or leave this to a schema validator 3rd party plugin maybe? And replace my custom class decoding (and also encoding?)?
# Or both: add encoding/decoding of more native classes, and allow decoding + applying a schema with 3rd party.
# Or encourage using Marshal from core?

# Extended with the `#to_nt` method.
class String include NestedText::NTEncodeMixin; end

# Extended with the `#to_nt` method.
class Array include NestedText::NTEncodeMixin; end

# Extended with the `#to_nt` method.
class Hash include NestedText::NTEncodeMixin; end

# Extended with NestedText support.
class NilClass
  include NestedText::NTEncodeMixin

  # Adds support for encoding and decoding nil.
  def self.nt_create(_data) = nil

  # Adds support for encoding and decoding nil.
  def encode_nt_with() = ""
end
