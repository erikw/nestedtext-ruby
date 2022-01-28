require "nestedtext/core_ext_internal"

module NestedText
  using NestedText.const_get(:CoreExtInternal)

  # Dumping with recursive DFS traversal of the object references.
  class Dumper
    def initialize(indentation, strict)
      @indentation = indentation
      @strict = strict
      @traced_cycles = nil
      @traced_keys = nil
    end

    def dump(obj)
      @traced_cycles = []
      @traced_keys = []
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

    def convert_key(key)
      if key.nil?
        ""
      elsif key.is_a? String
        key.normalize_line_endings
      elsif !@strict
        key.to_s
      else
        raise Errors::DumpHashKeyStrictStringError, key
      end
    end

    def indent(target)
      indentstr = " " * @indentation
      indented = "\n" + target.lines.map { |line| indentstr + line }.join
      target.replace indented
    end

    def trace_cycles(obj)
      raise Errors::DumpCyclicReferencesDetectedError, traced_key if @traced_cycles.include?(obj)

      @traced_cycles << obj
      yield
    ensure
      @traced_cycles.pop
    end

    def trace_keys(key)
      @traced_keys << key
      yield
    ensure
      @traced_keys.pop
    end

    def traced_key
      @traced_keys.last
    end

    def dump_any(obj, depth: 0, **kwargs)
      trace_cycles(obj) do
        case obj
        when Hash then dump_hash(obj, depth: depth, **kwargs)
        when Array then dump_array(obj, depth: depth, **kwargs)
        when String then dump_string(obj, depth: depth, **kwargs)
        when nil
          @strict ? "" : dump_custom_class(nil, depth: depth, **kwargs)
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
                trace_keys(key) do
                  key = convert_key(key)

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
                end
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
              obj.each_with_index.map do |e, i|
                trace_keys(i) do
                  e_rep = dump_any(e, depth: depth + 1, **kwargs)
                  Dumper.add_prefix("-", e_rep)
                end
              end.join("\n")
            end

      indent(rep) if depth > 0
      rep
    end

    def dump_string(obj, depth: 0, force_multiline: false)
      obj = obj.normalize_line_endings
      lines = obj.lines
      lines << "\n" if !lines.empty? && lines[-1][-1] == "\n"
      lines.each { |line| Dumper.add_prefix(">", line) } if lines.length > 1 || depth == 0 || force_multiline

      # Case of empty input string. No space after '>'
      lines << ">" if lines.empty? && (depth == 0 || force_multiline)

      rep = lines.join.chomp
      indent(rep) if !rep.empty? && depth > 0 && (rep.include?("\n") || force_multiline)
      rep
    end

    def dump_custom_class(obj, **kwargs)
      raise Errors::DumpUnsupportedTypeError.new(obj, traced_key) if @strict

      if obj.is_a? Symbol
        dump_string(obj.id2name, **kwargs)
      elsif obj.respond_to? :encode_nt_with
        class_name = obj.nil? ? "nil" : obj.class.name
        enc = { CUSTOM_CLASS_KEY => class_name, "data" => obj.encode_nt_with }
        dump_any(enc, **kwargs)
      else
        dump_string(obj.to_s, **kwargs)
      end
    end
  end
  private_constant :Dumper
end
