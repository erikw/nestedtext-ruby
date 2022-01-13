require "test_helper"

# TODO: test serializing custom classes
class TestOuter
  def initialize(_val)
    @val = vall
  end

  def to_nt(*args); end
end

class TestOuter
  def initialize(a, b, c)
    @data = [a, b]
    @inner = TestInner(c)
  end

  def to_nt(*args); end
end

# TODO: test symbols in array/hash: how encode them?
class EncodeToString < Minitest::Test
  def test_empty
    assert_nil NestedText.load("")
  end

  def test_array_empty
    assert_equal "", NestedText.dump([])
  end

  def test_array_one
    obj = ["an item here"]
    nts = <<~NT.chomp
      - an item here
    NT
    assert_equal nts, NestedText.dump(obj)
  end

  def test_array_two_strings
    obj = %w[a b]
    nts = <<~NT.chomp
      - a
      - b
    NT
    assert_equal nts, NestedText.dump(obj)
  end

  def test_array_nested_array
    obj = ["a", %w[b c]]
    nts = <<~NT.chomp
      - a
      -
          - b
          - c
    NT
    assert_equal nts, NestedText.dump(obj)
  end
end
