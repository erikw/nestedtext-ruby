# TODO: add forzen literal by using string#replace?
require 'nestedtext/core_ext_internal'

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

    def self.add_prefix(prefix, target)
      if target.empty? || target[0] == "\n"
        target.prepend(prefix)
      else
        target.prepend(prefix, ' ')
      end
    end

    def self.multiline_key?(key)
      syntax1 = '{[#'
      syntax2 = ':->'

      key.empty? ||
        key != key.strip ||
        key.include?("\n") ||
        key.include?(': ') ||
        syntax1.include?(key.lstrip[0]) ||
        (syntax2.include?(key.lstrip[0]) && key.lstrip[1] == ' ')
    end

    private

    def convert_key(key)
      if key.nil?
        ''
      elsif key.is_a? String
        key.normalize_line_endings
      elsif !@strict
        key.to_s
      else
        raise Errors::DumpHashKeyStrictStringError, key
      end
    end

    def indent(target, depth)
      return target unless depth.positive?

      indentstr = ' ' * @indentation
      "\n#{target.lines.map { |line| indentstr + line }.join}"
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
        when Hash then dump_hash(obj, depth:, **kwargs)
        when Array then dump_array(obj, depth:, **kwargs)
        when String then dump_string(obj, depth:, **kwargs)
        when nil
          @strict ? '' : dump_custom_class(nil, depth:, **kwargs)
        else
          dump_custom_class(obj, depth:, **kwargs)
        end
      end
    end

    def dump_hash_key_multiline(key, value, depth, **kwargs)
      key_lines = key.empty? ? [''] : key.lines
      key_lines << '' if key_lines[-1][-1] =~ /\n|\r/
      rep_key = key_lines.map { |line| Dumper.add_prefix(':', line) }.join
      force_multiline = value.is_a? String
      rep_value = dump_any(value, depth: depth + 1, force_multiline:, **kwargs)
      [rep_key, rep_value].join
    end

    def dump_hash_key(key, value, depth, **kwargs)
      rep_key = "#{key}:"
      rep_value = dump_any(value, depth: depth + 1, **kwargs)
      rep_key += ' ' unless rep_value.empty? || rep_value.include?("\n")
      [rep_key, rep_value].join
    end

    def dump_hash_items(hash, depth, **kwargs)
      hash.map do |key, value|
        trace_keys(key) do
          key = convert_key(key)
          if Dumper.multiline_key?(key)
            dump_hash_key_multiline(key, value, depth, **kwargs)
          else
            dump_hash_key(key, value, depth, **kwargs)
          end
        end
      end.join("\n")
    end

    def dump_hash(hash, depth: 0, **kwargs)
      rep = hash.empty? ? '{}' : dump_hash_items(hash, depth, **kwargs)
      indent(rep, depth)
    end

    def dump_array(array, depth: 0, **kwargs)
      rep = if array.empty?
              # TODO: replace this special case with simply general inline rendering detection.
              '[]'
            else
              array.each_with_index.map do |e, i|
                trace_keys(i) do
                  e_rep = dump_any(e, depth: depth + 1, **kwargs)
                  Dumper.add_prefix('-', e_rep)
                end
              end.join("\n")
            end

      indent(rep, depth)
    end

    def dump_string(string, depth: 0, force_multiline: false)
      lines = string.normalize_line_endings.lines
      lines << '' if !lines.empty? && lines.last[-1] == "\n"
      multiline = lines.length > 1 || force_multiline

      lines.each { |line| Dumper.add_prefix('>', line) } if multiline || depth.zero?

      lines << '>' if lines.empty? && (depth.zero? || multiline)

      rep = lines.join.chomp
      multiline ? indent(rep, depth) : rep
    end

    def dump_custom_class(obj, **kwargs)
      raise Errors::DumpUnsupportedTypeError.new(obj, traced_key) if @strict

      if obj.is_a? Symbol
        dump_string(obj.id2name, **kwargs)
      elsif obj.respond_to? :encode_nt_with
        class_name = obj.nil? ? 'nil' : obj.class.name
        enc = { CUSTOM_CLASS_KEY => class_name, 'data' => obj.encode_nt_with }
        dump_any(enc, **kwargs)
      else
        dump_string(obj.to_s, **kwargs)
      end
    end
  end
  private_constant :Dumper
end
