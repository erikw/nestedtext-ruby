# frozen_string_literal: true

require "nestedtext/dumper"
require "nestedtext/errors_internal"

module NestedText
  # Encode a Ruby object to a NestedText string.
  #
  # [obj] The object to encode to NestedText.
  # [io] Additionally write the output to this IO object. The caller is responsible for that the IO is closed after the call to this method.
  # [indentation] The indentation of nested levels to use.
  # [strict] If strict mode should be used. +true+ or +false+. Default is +false+
  #
  # Returns a String containing NestedText data.
  #
  # Raises NestedText::Error if anything went wrong.
  #
  # Raises whatever the passed +io+ can raise.
  def self.dump(obj, io: nil, indentation: 4, strict: false)
    raise Errors::DumpBadIOError, io unless io.nil? || io.respond_to?(:write) && io.respond_to?(:fsync)

    dumper = Dumper.new(indentation, strict)
    result = dumper.dump obj
    unless io.nil?
      io.write(result)
      io.fsync
    end
    dumper.dump obj
  end

  # Encode a Ruby object to a NestedText file.
  #
  # [filename] The file path to write the NestedText result to. The conventional file extension is +.nt+.
  #
  # Raises +IOError+ on issues opening the +filename+ for writing in text mode.
  #
  # Apart from +filename+, this method behaves exactly like dump (taking same arguments, returning and raising the same values).
  def self.dump_file(obj, filename, **kwargs)
    raise Errors::DumpFileBadPathError, filename unless filename.is_a? String

    File.open(filename, mode = "wt") do |file|
      dump(obj, io: file, **kwargs)
    end
  end
end
