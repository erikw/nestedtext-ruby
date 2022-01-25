require "nestedtext/encode_helpers"

# TODO: add encoding of more Ruby native classes like Integer, Float etc plus commons like Set,....? Not covered in NestedText language.
# Or leave this to a schema validator 3rd party plugin maybe? And replace my custom class decoding (and also encoding?)?
# Or both: add encoding/decoding of more native classes, and allow decoding + applying a schema with 3rd party.
# Or encourage using Marshal from core?

NT_MIXIN = NestedText.const_get(:NTEncodeStrictMixin)
class String include NT_MIXIN end
class Array include NT_MIXIN end
class Hash include NT_MIXIN end

class NilClass
  include NT_MIXIN

  def self.nt_create(_data) = nil

  def encode_nt_with() = ""
end
