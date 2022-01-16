require "nestedtext/encode_helpers"

# TODO: add encoding of more Ruby native classes like Integer, Float etc.? Not covered in NestedText language.
# Or leave this to a schema validator 3rd party plugin maybe? And replace my custom class decoding (and also encoding?)?
# Or both: add encoding/decoding of more native classes, and allow decoding + applying a schema with 3rd party.
# Or encourage using Marshal from core?

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
      e_rep = if e.nil?
                ["class__nil", []].to_nt(opts: opts, depth: depth + 1)
              elsif e.respond_to? :to_nt
                e.to_nt(opts: opts, depth: depth + 1)
              else
                # raise "Can not encode#{e.class} as it does not implement #to_nt. Either implement this method, of manually serialize the class using NestedText native types, use Marshal, or use a 3rd party schema library."
                raise "unsupported type (#{e.class.name})."
              end
      NestedText.add_prefix("#{indent}-", e_rep)
    end.join("\n")
    rep.prepend("\n") if length > 0 && depth > 0
    rep
  end
end
