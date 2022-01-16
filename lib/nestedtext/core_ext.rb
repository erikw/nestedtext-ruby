require "nestedtext/encode_helpers"

class String
  def to_nt(opts: NestedText::EncodeOptions.new, depth: 0)
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
  def to_nt(opts: NestedText::EncodeOptions.new, depth: 0)
    indent = " " * opts.indentation * depth
    rep = each.map do |e|
      NestedText.add_prefix("#{indent}-", e.to_nt(opts: opts, depth: depth + 1))
    end.join("\n")
    rep.prepend("\n") if length > 0 && depth > 0
    rep
  end
end
