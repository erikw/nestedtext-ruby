require "nestedtext/encode_helpers"

class String
  def to_nt(**_kwargs)
    self
  end
end

class Array
  def to_nt(level: 0, indentation: 4, **kwargs)
    indent = " " * indentation * level
    rep = each.map do |e|
      indent + NestedText.add_prefix("-", e.to_nt(level: level + 1, indentation: indentation, **kwargs))
    end.join("\n")
    rep.prepend("\n") if length > 0 && level > 0
    rep
  end
end
