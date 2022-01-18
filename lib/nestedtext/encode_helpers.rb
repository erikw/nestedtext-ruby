module NestedText
  class EncodeOptions
    attr_reader :indentation, :strict

    def initialize(indentation = 4, strict = true)
      @indentation = indentation
      @strict = strict
    end
  end
end
