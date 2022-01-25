require "stringio"
module NestedText
  TOP_LEVEL_TYPES = [Object, Hash, Array, String]
  CUSTOM_CLASS_KEY = "__nestedtext_class__"

  private_constant :TOP_LEVEL_TYPES, :CUSTOM_CLASS_KEY
end
