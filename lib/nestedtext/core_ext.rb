require "nestedtext/encode_helpers"

class String
  def to_nt(**_kwargs)
    self
  end
end

class Array
  # TODO: how pass level & indentatin with default values? and make it easy for developers to make their own to_nt?
  # Better to do like psych's #encode_with?
  def to_nt(indentation: 4, **_kwargs)
    indent = " " * indentation
    rep = each.map do |e|
      indent + NestedText.add_prefix("-", e.to_nt(indentation: indentation + 4))
    end.join("\n")
    rep.prepend("\n") if length > 0 && indentation > 0
    rep
  end
end
