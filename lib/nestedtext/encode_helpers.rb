module NestedText
  def self.add_prefix(prefix, target)
    if target[0] == "\n"
      target.prepend(prefix)
    else
      target.prepend(prefix, " ")
    end
  end
end
