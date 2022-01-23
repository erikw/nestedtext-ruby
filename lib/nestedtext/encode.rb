# frozen_string_literal: true

require "nestedtext/errors"
require "nestedtext/encode_helpers"
require "nestedtext/dumper"

# Model after JSON
# NestedText.dump(obj, io=nil) => dumps to string, or to IO if given
# NestedText.dump_file(obj, filename)

module NestedText
  # TODO: strict should maybe be false by default, as this is what ntpy does. If so, make the same for the load functions.
  def self.dump(obj, io: nil, indentation: 4, strict: true)
    # IO additionaly write the out result to IO and still return result.

    # Idea #1
    # * core_ext.rb adds accept(visitor) to Array, Hash, Enumarable etc like https://medium.com/kkempin/visitor-design-pattern-in-ruby-bc07395c4abc
    #    * https://refactoring.guru/design-patterns/visitor/ruby/example
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
    #     - NT supported types simply call NestedText.dump(self).
    #     - custom objects call self.encode_nt_with.to_nt. This method can be a mixin as it's generic!
    #        - #encode_nt_with returns the ["class__", data]
    #  * NestedText#dump will work recursively and switching on object type
    #        - NT supported types handled directly
    #        - custom objects: check respond_to? encode_nt_with and continue recursing on the returned array

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
