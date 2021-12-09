require "test_helper"

class DecodeTest < Minitest::Test
  def test_empty
    assert_equal({}, NestedText.load(""))
  end

  def test_empty_whitespace
    assert_equal({}, NestedText.load("  "))
  end

  def test_dict_single_entry
    assert_equal({ "a" => "b" }, NestedText.load("a: b"))
  end
end
