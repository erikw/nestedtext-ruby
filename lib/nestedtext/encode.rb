# frozen_string_literal: true

require "nestedtext/dumper"
require "nestedtext/errors_internal"

module NestedText
  def self.dump(obj, io: nil, indentation: 4, strict: false)
    # io - additionaly write the out result to IO and still return result.

    raise Errors::DumpBadIOError, io unless io.nil? || io.respond_to?(:write) && io.respond_to?(:fsync)

    dumper = Dumper.new(indentation, strict)
    result = dumper.dump obj
    unless io.nil?
      io.write(result)
      io.fsync
    end
    dumper.dump obj
  end

  def self.dump_file(obj, filename, **kwargs)
    raise Errors::DumpFileBadPathError, filename unless filename.is_a? String

    File.open(filename, mode = "wt") do |file|
      dump(obj, io: file, **kwargs)
    end
  end
end
