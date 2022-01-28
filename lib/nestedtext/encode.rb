# frozen_string_literal: true

require 'nestedtext/dumper'
require 'nestedtext/errors_internal'

module NestedText
  # Encode a Ruby object to a NestedText string.
  #
  # @param obj [Object] The object to encode to NestedText.
  # @param io [IO] Additionally write the output to this IO object. The caller is responsible for that the IO is closed after the call to this method.
  # @param indentation [Integer] The indentation of nested levels to use.
  # @param strict [Boolean] If strict mode should be used.
  #
  # @return [String, nil] A String containing NestedText data, or nil when obj is represented as empty.
  # @raise [NestedText::Error] if anything went wrong.
  # @raise Whatever the `io` can raise, if supplied.
  def self.dump(obj, io: nil, indentation: 4, strict: false)
    raise Errors::DumpBadIOError, io unless io.nil? || (io.respond_to?(:write) && io.respond_to?(:fsync))

    dumper = Dumper.new(indentation, strict)
    result = dumper.dump obj
    unless io.nil?
      io.write(result)
      io.fsync
    end
    dumper.dump obj
  end

  # Encode a Ruby object to a NestedText file.

  # Apart from `filename`, this method behaves exactly like dump.
  #
  # @param (see dump)
  # @param filename [String] The file path to write the NestedText result to. The conventional file extension is `.nt`.
  #
  #
  # @return (see dump)
  # @raise (see dump)
  # @raise [IOError] on issues opening the `filename` for writing in text mode.
  #
  def self.dump_file(obj, filename, **kwargs)
    raise Errors::DumpFileBadPathError, filename unless filename.is_a? String

    File.open(filename, mode = 'wt') do |file|
      dump(obj, io: file, **kwargs)
    end
  end
end
