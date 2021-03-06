# frozen_string_literal: true

require 'test_helper'

module CustomTestClasses
  class Inner
    include NestedText::ToNTMixin
    def initialize(val)
      @val = val
    end

    def self.nt_create(data)
      new(data)
    end

    def encode_nt_with
      @val
    end

    def ==(other)
      other.class == self.class && other.state == state
    end
    alias eql? ==

    protected

    def state
      [@val]
    end
  end

  class Outer
    def initialize(attr_a, attr_b, inner)
      @list = [attr_a, attr_b]
      @inner = inner
    end

    def self.nt_create(data)
      new(*data)
    end

    def encode_nt_with
      [*@list, @inner]
    end

    def ==(other)
      other.class == self.class && other.state == state
    end
    alias eql? ==

    protected

    def state
      [@list, @inner]
    end
  end

  class Node
    attr_reader :value
    attr_accessor :nxt

    def self.from_enum(enum)
      head = nil
      node = nil
      enum.each do |e|
        nnode = Node.new(e)
        head = nnode if head.nil?
        node.nxt = nnode unless node.nil?
        node = nnode
      end
      head
    end

    def initialize(value, nxt = nil)
      @value = value
      @nxt = nxt
    end

    def ==(other)
      other.class == self.class && other.state == state
    end
    alias eql? ==

    def self.nt_create(data)
      value = data[0]
      nxt = data[1]
      new(value, nxt)
    end

    def encode_nt_with
      [@value, @nxt]
    end

    protected

    def state
      [@value, @nxt]
    end
  end

  class NotNTEncodable
    def to_s
      'but it has an to_s method that will be called to represent the object'
    end
  end
end

class EncodeCustomClassTest < NTTest
  def test_custom_class_nil
    obj = nil
    exp = <<~NT.chomp
      __nestedtext_class__: nil
      data:
    NT
    dumped = NestedText.dump(obj)
    assert_equal exp, dumped

    loaded = NestedText.load(dumped)
    assert_nil loaded
  end

  def test_custom_class_nested
    outer = CustomTestClasses::Outer.new('a', 'b', CustomTestClasses::Inner.new('c'))
    obj = [outer]
    exp = <<~NT.chomp
      -
          __nestedtext_class__: CustomTestClasses::Outer
          data:
              - a
              - b
              -
                  __nestedtext_class__: CustomTestClasses::Inner
                  data: c
    NT
    dumped = NestedText.dump(obj)
    assert_equal exp, dumped

    loaded = NestedText.load(dumped)
    assert_equal obj, loaded
  end

  def test_custom_class_nested_indented
    obj = CustomTestClasses::Outer.new('a', 'b', CustomTestClasses::Inner.new('c'))
    exp = <<~NT.chomp
      __nestedtext_class__: CustomTestClasses::Outer
      data:
        - a
        - b
        -
          __nestedtext_class__: CustomTestClasses::Inner
          data: c
    NT
    dumped = NestedText.dump(obj, indentation: 2)
    assert_equal exp, dumped

    loaded = NestedText.load(dumped)
    assert_equal obj, loaded
  end

  def test_custom_class_method_to_nt
    obj = CustomTestClasses::Inner.new('a')
    exp = <<~NT.chomp
      __nestedtext_class__: CustomTestClasses::Inner
      data: a
    NT
    dumped = obj.to_nt(indentation: 2)
    assert_equal exp, dumped
  end

  def test_custom_class_linked_list
    obj = CustomTestClasses::Node.from_enum(%w[a b c])
    exp = <<~NT.chomp
      __nestedtext_class__: CustomTestClasses::Node
      data:
          - a
          -
              __nestedtext_class__: CustomTestClasses::Node
              data:
                  - b
                  -
                      __nestedtext_class__: CustomTestClasses::Node
                      data:
                          - c
                          -
                              __nestedtext_class__: nil
                              data:
    NT
    dumped = NestedText.dump(obj)
    assert_equal exp, dumped

    loaded = NestedText.load(dumped)
    assert_equal obj, loaded
  end

  def test_custom_class_not_encodeable
    obj = CustomTestClasses::NotNTEncodable.new
    exp = '> but it has an to_s method that will be called to represent the object'
    assert_equal exp, NestedText.dump(obj)
  end

  def test_custom_class_strict_true
    obj = CustomTestClasses::Inner.new('c')
    assert_raises(ERRORS::DumpUnsupportedTypeError) do
      NestedText.dump(obj, strict: true)
    end
  end
end
