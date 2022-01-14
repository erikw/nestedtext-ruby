require "nestedtext/encode_helpers"

class String
  def to_nt(depth: 0, **_kwargs)
    rep = dup
    NestedText.add_prefix(">", rep) if rep.include?("\n") || depth == 0
    rep
  end
end

class Array
  def to_nt(depth: 0, indentation: 4, **kwargs)
    indent = " " * indentation * depth
    rep = each.map do |e|
      NestedText.add_prefix("#{indent}-", e.to_nt(depth: depth + 1, indentation: indentation, **kwargs))
    end.join("\n")
    rep.prepend("\n") if length > 0 && depth > 0
    rep
  end
end
