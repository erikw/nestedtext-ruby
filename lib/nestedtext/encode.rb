# frozen_string_literal: true

require "nestedtext/errors"
require "nestedtext/encode_helpers"

# Model after JSON
# NestedText.dump(obj, io=nil) => dumps to string, or to IO if given
# NestedText.dump_file(obj, filename)

module NestedText
  def self.dump(obj, io: nil, indentation: 4)
    # Idea #1
    # * core_ext.rb adds accept(visitor) to Array, Hash, Enumarable etc like https://medium.com/kkempin/visitor-design-pattern-in-ruby-bc07395c4abc
    # * Visitor base class has dynamic dispatch built-in based on class of visited object like in https://github.com/ruby/psych/blob/master/lib/psych/visitors/visitor.rb#L14
    # Release 2: * Check object with #respond_to "to_nt" for custom representation ? Otherwise use #to_s, or #inspect?
    #   * and #nt_create like #json_create to read back! https://www.py4u.net/discuss/2207640
    #     * encode_with like psych? https://stackoverflow.com/questions/18178098/how-do-i-have-ruby-yaml-dump-a-hash-subclass-as-a-simple-hash#18178935
    #   * Need to store as hash with class name as one value as in JSON, https://ruby-doc.org/stdlib-3.1.0/libdoc/json/rdoc/JSON.html#module-JSON-label-Custom+JSON+Additions
    #
    # Question: how carry state with us in visitor like current indentation depth? A state in the visitor, or data/state/options hash that goes in both visit() and accept()?
    #
    #  Idea #2
    #  * Simply to_nt(*args) on each object and no visitor. state like indentation passed down in args. to_nt returns the final nt representation
    #  * To support serialization/deserialization, add class name like in to_json()
    #
    # Problem: to detect cyclic references, it becomes too burdensome in custom #to_nt to add self to call list and then remove after
    # Solution:
    #  * let #to_nt on
    #     - NT supported types simply call NestedText.dump(self)
    #     - custom objects call self.encode_nt_with.to_nt
    #        - #encode_nt_with returns the ["class__", data]
    #     - NestedText#dump will work recursively and switching on object type
    #        - NT supported types handled directly
    #        - custom objects: check respond_to? encode_nt_with and continue recursing on the returned array

    return "" if obj.nil?

    opts = EncodeOptions.new(indentation)
    obj.to_nt(opts: opts) if obj.respond_to? :to_nt
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
