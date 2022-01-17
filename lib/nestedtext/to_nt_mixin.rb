require "nestedtext/dumper"
require "nestedtext/encode_helpers"

module NestedText
  module NTEncodeMixing
    def to_nt(indentation: 4)
      Dumper.new(EncodeOptions.new(indentation)).dump self
    end
  end
end
