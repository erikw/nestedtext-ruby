module NestedText
  class EncodeOptions
    attr_reader :indentation

    def initialize(indentation = 4)
      @indentation = indentation
    end
  end
end
