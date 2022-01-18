require "nestedtext/dumper"
require "nestedtext/encode_helpers"

module NestedText
  module NTEncodeStrictMixing
    def to_nt(indentation: 4, strict: true)
      Dumper.new(EncodeOptions.new(indentation, strict)).dump self
    end
  end

  module NTEncodeMixing
    def to_nt(indentation: 4)
      Dumper.new(EncodeOptions.new(indentation, false)).dump self
    end
  end
end
