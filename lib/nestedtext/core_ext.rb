require "nestedtext/to_nt_mixin"

# TODO: add encoding of more Ruby native classes like Integer, Float etc.? Not covered in NestedText language.
# Or leave this to a schema validator 3rd party plugin maybe? And replace my custom class decoding (and also encoding?)?
# Or both: add encoding/decoding of more native classes, and allow decoding + applying a schema with 3rd party.
# Or encourage using Marshal from core?

class String include NestedText::NTEncodeStrictMixing end
class Array include NestedText::NTEncodeStrictMixing end
