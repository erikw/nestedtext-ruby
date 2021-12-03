require "test_helper"

class DecodeTest < Minitest::Test
  def test_empty
    assert_equal NestedText.load(""), {}
  end

  def test_empty_whitespace
    assert_equal NestedText.load(" \t "), {}
  end

  def test_dict_single_entry
    assert_equal NestedText.load("a: b"), { a: "b" }
  end
end
