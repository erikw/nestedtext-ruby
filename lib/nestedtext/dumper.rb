module NestedText
  class Dumper
    def initialize(opts = EncodeOptions.new)
      @indentation = opts.indentation
      @strict = opts.strict
    end

    def dump(obj)
      dump_any obj
    end

    private

    def self.add_prefix(prefix, target)
      if target.empty? || target[0] == "\n"
        target.prepend(prefix)
      else
        target.prepend(prefix, " ")
      end
    end

    def self.multiline_key?(key)
      syntax1 = "{[#"
      syntax2 = ":->"

      key.empty? ||
        key.include?("\n") ||
        key =~ /^\s+$/ ||
        syntax1.include?(key.lstrip[0]) ||
        syntax2.include?(key.lstrip[0]) && key.lstrip[1] == " "
    end

    def indent(target)
      indentstr = " " * @indentation
      "\n" + target.lines.map { |line| indentstr + line }.join
    end

    def dump_any(obj, depth: 0, **kwargs)
      case obj
      when Hash then dump_hash(obj, depth: depth, **kwargs)
      when Array then dump_array(obj, depth: depth, **kwargs)
      when String then dump_string(obj, depth: depth, **kwargs)
      when nil
        if @strict
          ""
        else
          dump_any(["class__nil", []], depth: depth, **kwargs)
        end
      else
        if obj.respond_to? :encode_nt_with
          dump_any(obj.encode_nt_with, depth: depth, **kwargs)
        else
          raise Errors::DumpUnsupportedTypeError, obj
        end
      end
    end

    def dump_hash(obj, depth: 0, **kwargs)
      rep = if depth == 0 && obj.empty?
              "{}"
            else
              obj.map do |key, value|
                key = "" if key.nil?
                if Dumper.multiline_key?(key)
                  key_lines = key.empty? ? [""] : key.lines(chomp: true)
                  rep_key = key_lines.map { |line| Dumper.add_prefix(":", line) }.join("\n")
                  force_multiline = value.is_a? String
                  rep_value = dump_any(value, depth: depth + 1, force_multiline: force_multiline, **kwargs)
                else
                  rep_key = "#{key}:"
                  rep_value = dump_any(value, depth: depth + 1, **kwargs)
                  rep_key += " " unless rep_value.empty? || rep_value.include?("\n")
                end
                "#{rep_key}#{rep_value}"
              end.join("\n")
            end
      rep = indent(rep) if !obj.empty? && depth > 0
      rep
    end

    def dump_array(obj, depth: 0, **kwargs)
      rep = if depth == 0 && obj.empty?
              # TODO: replace this special case with simply general inline rendering detection.
              "[]"
            else
              obj.each.map do |e|
                e_rep = dump_any(e, depth: depth + 1, **kwargs)
                Dumper.add_prefix("-", e_rep)
              end.join("\n")
            end

      rep = indent(rep) if !obj.empty? && depth > 0
      rep
    end

    def dump_string(obj, depth: 0, force_multiline: false)
      lines = obj.lines
      lines << "\n" if !lines.empty? && lines[-1][-1] == "\n"
      if lines.length > 1 || depth == 0 || force_multiline
        lines.each do |line|
          Dumper.add_prefix(">", line)
        end
      end

      # Case of empty input string. No space after '>'
      lines << ">" if lines.empty? && (depth == 0 || force_multiline)

      rep = lines.join.chomp
      rep = indent(rep) if !rep.empty? && depth > 0 && (rep.include?("\n") || force_multiline)
      rep
    end
  end
end
