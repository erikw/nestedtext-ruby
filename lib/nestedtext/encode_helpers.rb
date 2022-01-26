require "nestedtext/dumper"

module NestedText
  module NTEncodeStrictMixin
    def to_nt(**kwargs)
      NestedText.dump(self, strict: true, **kwargs)
    end
  end
  private_constant :NTEncodeStrictMixin

  module NTEncodeMixin
    def to_nt(**kwargs)
      NestedText.dump(self, **kwargs)
    end
  end
end
