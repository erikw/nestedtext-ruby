require "test_helper"

# TODO: test serializing custom classes
class Inner
  def initialize(val)
    @val = val
  end

  def to_nt(**_kwargs)
    @val.to_nt
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
  def initialize(a, b, c)
    @data = [a, b]
    @inner = Inner.new(c)
  end

  def to_nt(**kwargs)
    # TODO: create helper method NestedText.EncodeClassKey(klass) to generate key name
    # See https://github.com/ruby/psych/blob/master/lib/psych/visitors/visitor.rb#L14
    ["class__Outer", @data + [@inner]].to_nt(**kwargs)
  end

  def self.nt_create(object)
    new(*object[1])
  end

  def ==(other)
    other.class == self.class && other.state == state
  end
  alias eql? ==

  protected

  def state
    [@data, @inner]
  end
end

class EncodeToString < Minitest::Test
  def test_empty
    assert_nil NestedText.load("")
  end
end

class EncodeToStringArray < Minitest::Test
  def test_array_empty
    assert_equal "", NestedText.dump([])
  end

  def test_array_one
    obj = ["an item here"]
    exp = <<~NT.chomp
      - an item here
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_two_strings
    obj = %w[a b]
    exp = <<~NT.chomp
      - a
      - b
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_nested_array_first
    obj = [%w[a b], "c"]
    exp = <<~NT.chomp
      -
          - a
          - b
      - c
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_nested_array_last
    obj = ["a", %w[b c]]
    exp = <<~NT.chomp
      - a
      -
          - b
          - c
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_nested_array_middle
    obj = ["a", %w[b c], "d"]
    exp = <<~NT.chomp
      - a
      -
          - b
          - c
      - d
    NT
    assert_equal exp, NestedText.dump(obj)
  end
end

# TODO: test symbols in array/hash: how encode them?
class EncodeToStringHash < Minitest::Test
end

class EncodeToStringString < Minitest::Test
  def test_string_empty
    assert_equal ">", NestedText.dump("")
  end

  def test_string_simple
    obj = "  a string with\twords"
    exp = <<~NT.chomp
      > #{obj}
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_multiline
    obj = "  a string\t\n\twith multiple\nlines"
    exp = <<~NT.chomp
      >   a string\t
      > \twith multiple
      > lines
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  # TODO: test trailing double line feed, and \n\t\n \n
  def test_string_multiline_trailing_linefeed
    obj = "multi-line\nwith trailing line\n"
    exp = <<~NT.chomp
      > multi-line
      > with trailing line
      >
    NT
    assert_equal exp, NestedText.dump(obj)
  end
end

class EncodeToStingCustomClass
  def test_custom_class_nested
    outer = Outer.new("a", "b", "c")
    obj = [[outer]]
    exp = <<~NT.chomp
      -
          -
              - class__Outer
              -
                  - a
                  - b
                  - c
    NT
    dumped = NestedText.dump(obj)
    assert_equal exp, dumped

    loaded = NestedText.load(dumped)
    assert_equal obj, loaded
  end
end
