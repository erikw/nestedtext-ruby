# TODO: is this exposed to client who import this file? If so, hide it!
class String
  def normalize_line_endings
    # windows/mac -> unix
    gsub(/\r\n?/, "\n")
  end
end

module NestedText
  class Dumper
    def initialize(opts = EncodeOptions.new)
      @indentation = opts.indentation
      @strict = opts.strict
      @trace = nil
    end

    def dump(obj)
      @trace = []
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
        key != key.strip ||
        key.include?("\n") ||
        key.include?(": ") ||
        syntax1.include?(key.lstrip[0]) ||
        syntax2.include?(key.lstrip[0]) && key.lstrip[1] == " "
    end

    def indent(target)
      indentstr = " " * @indentation
      indented = "\n" + target.lines.map { |line| indentstr + line }.join
      target.replace indented
    end

    def trace(obj)
      raise Errors::DumpCyclicReferencesDetected if @trace.include?(obj)

      @trace << obj
      yield
    ensure
      @trace.pop
    end

    def dump_any(obj, depth: 0, **kwargs)
      trace(obj) do
        case obj
        when Hash then dump_hash(obj, depth: depth, **kwargs)
        when Array then dump_array(obj, depth: depth, **kwargs)
        when String then dump_string(obj, depth: depth, **kwargs)
        when Symbol then dump_string(obj.id2name, depth: depth, **kwargs)
        when nil
          @strict ? "" : dump_custom_class(obj, depth: depth, **kwargs)
        else
          dump_custom_class(obj, depth: depth, **kwargs)
        end
      end
    end

    def dump_hash(obj, depth: 0, **kwargs)
      rep = if obj.empty?
              "{}"
            else
              obj.map do |key, value|
                key = "" if key.nil?
                key = key.id2name if key.is_a? Symbol
                key = key.normalize_line_endings

                if Dumper.multiline_key?(key)
                  key_lines = key.empty? ? [""] : key.lines
                  key_lines << "" if key_lines[-1][-1] =~ /\n|\r/
                  rep_key = key_lines.map { |line| Dumper.add_prefix(":", line) }.join
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
      indent(rep) if depth > 0
      rep
    end

    def dump_array(obj, depth: 0, **kwargs)
      rep = if obj.empty?
              # TODO: replace this special case with simply general inline rendering detection.
              "[]"
            else
              obj.each.map do |e|
                e_rep = dump_any(e, depth: depth + 1, **kwargs)
                Dumper.add_prefix("-", e_rep)
              end.join("\n")
            end

      indent(rep) if depth > 0
      rep
    end

    def dump_string(obj, depth: 0, force_multiline: false)
      obj = obj.normalize_line_endings
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
      indent(rep) if !rep.empty? && depth > 0 && (rep.include?("\n") || force_multiline)
      rep
    end

    def dump_custom_class(obj, **kwargs)
      raise Errors::DumpCustomClassStrictMode, obj if @strict

      if obj.respond_to? :encode_nt_with
        class_name = obj.nil? ? "nil" : obj.class.name
        enc = { CUSTOM_CLASS_KEY => class_name, "data" => obj.encode_nt_with }
        dump_any(enc, **kwargs)
      else
        raise Errors::DumpUnsupportedTypeError, obj
      end
    end
  end
end
