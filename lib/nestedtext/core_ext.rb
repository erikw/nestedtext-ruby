require "nestedtext/encode_helpers"

class String
  def to_nt(*_args)
    self
  end
end

class Array
  def to_nt(indentation: 0)
    indent = " " * indentation
    rep = each.map do |e|
      indent + NestedText.add_prefix("-", e.to_nt(indentation: indentation + 4))
    end.join("\n")
    rep.prepend("\n") if length > 0 && indentation > 0
    rep
  end
end
