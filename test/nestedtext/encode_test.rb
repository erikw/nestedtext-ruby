require "test_helper"

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
end
