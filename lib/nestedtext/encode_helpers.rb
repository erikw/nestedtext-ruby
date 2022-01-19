require "nestedtext/dumper"

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

  class EncodeOptions
    attr_reader :indentation, :strict

    def initialize(indentation = 4, strict = true)
      @indentation = indentation
      @strict = strict
    end
  end

  def self.EncodeWithData(owner, data, name_override = nil)
    class_name = name_override.nil? ? owner.class.name : name_override
    { "__nestedtext_class__" => class_name, "data" => data }
  end
end
