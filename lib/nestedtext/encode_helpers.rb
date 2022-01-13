module NestedText
  def self.add_prefix(prefix, target)
    if target[0] == "\n"
      prefix + target
    else
      prefix + " " + target
    end
  end
end
