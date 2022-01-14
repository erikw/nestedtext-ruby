require "nestedtext/encode_helpers"

class String
  def to_nt(depth: 0, **_kwargs)
    rep_lines = lines
    rep_lines << "\n" if !rep_lines.empty? && rep_lines[-1][-1] == "\n"
    if rep_lines.length > 1 || depth == 0
      rep_lines.each do |line|
        NestedText.add_prefix(">", line)
      end
    end

    # Case of empty input string. No space after '>'
    rep_lines << ">" if rep_lines.empty?

    rep_lines.join.chomp
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
