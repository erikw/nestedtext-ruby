# frozen_string_literal: true

require "nestedtext/errors"
require "nestedtext/encode_helpers"
require "nestedtext/dumper"

# Model after JSON
# NestedText.dump(obj, io=nil) => dumps to string, or to IO if given
# NestedText.dump_file(obj, filename)

module NestedText
  def self.dump(obj, io: nil, indentation: 4, strict: false)
    # io - additionaly write the out result to IO and still return result.

    raise Errors::DumpBadIO, io unless io.nil? || io.respond_to?(:write) && io.respond_to?(:fsync)

    opts = EncodeOptions.new(indentation, strict)
    dumper = Dumper.new(opts)
    result = dumper.dump obj
    unless io.nil?
      io.write(result)
      io.fsync
    end
    result
  end

  def self.dump_file(obj, filename, **kwargs)
    raise Errors::DumpFileBadPath, filename unless filename.is_a? String

    File.open(filename, mode = "wt") do |file|
      dump(obj, io: file, **kwargs)
    end
  end
end
