module NestedText
  class EncodeOptions
    attr_reader :indentation

    def initialize(indentation: 4)
      @indentation = indentation
    end
  end

  def self.add_prefix(prefix, target)
    if target[0] == "\n"
      target.prepend(prefix)
    else
      target.prepend(prefix, " ")
    end
  end
end
