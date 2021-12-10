require "test_helper"

class DecodeTopTest < Minitest::Test
  def test_top_invalid_enumerable
    assert_raises(NestedText::Errors::UnsupportedTopLevelTypeError) do
      NestedText.load("", top: Enumerable)
    end
  end

  def test_top_invalid_nil
    assert_raises(NestedText::Errors::UnsupportedTopLevelTypeError) do
      NestedText.load("", top: nil)
    end
  end

  def test_input_invalid_array
    assert_raises(NestedText::Errors::WrongInputTypeError) do
      NestedText.load([])
    end
  end

  def test_input_invalid_hash
    assert_raises(NestedText::Errors::WrongInputTypeError) do
      NestedText.load({})
    end
  end
end

class DecodeStringTopAnyTest < Minitest::Test
  def test_empty
    assert_nil NestedText.load("")
  end

  def test_empty_top_any
    assert_nil NestedText.load("", top: Object)
  end

  def test_empty_whitespace
    assert_nil NestedText.load("  ")
  end

  def test_top_empty_dict_single_entry
    assert_equal({ "a" => "b" }, NestedText.load("a: b"))
  end

  def test_top_empty_dict_two_entries
    assert_equal({ "a" => "b", "5" => "7" }, NestedText.load("a: b\n5: 7"))
  end
end

class DecodeStringTopHashTest < Minitest::Test
  def test_top_hash_dict_empty
    assert_equal({}, NestedText.load("", top: Hash))
  end

  def test_top_hash_empty_whitespace
    assert_equal({}, NestedText.load("  ", top: Hash))
  end
end

# TODO: class DecodeFile...Test
