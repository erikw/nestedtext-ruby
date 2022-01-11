# frozen_string_literal: true

require "nestedtext/errors"

# Model after JSON
# NestedText.dump(obj, io=nil) => dumps to string, or to IO if given
# NestedText.dump_file(obj, filename)

# TODO: Need to check for circular dependencies! See JSON.fast_generate
module NestedText
  def self.dump(_obj, _io = nil)
    raise Errors::WrongInputTypeError.new([String], ntstring) unless ntstring.nil? || ntstring.is_a?(String)

    assert_valid_top_level_type top_class

    Parser.new(StringIO.new(ntstring), top_class).parse
  end

  # def self.load_file(filename, top_class: Object)
  # raise Errors::WrongInputTypeError.new([String], filename) unless filename.nil? || filename.is_a?(String)

  # assert_valid_top_level_type top_class

  ## Open explicitly in text mode to detect \r as line ending.
  # File.open(filename, mode = "rt") do |file|
  # Parser.new(file, top_class).parse
  # end
  # end
end
