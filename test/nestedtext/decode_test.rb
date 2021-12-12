require "test_helper"

class DecodeTopTest < Minitest::Test
  def test_top_invalid_enumerable
    assert_raises(NestedText::Errors::UnsupportedTopLevelTypeError) do
      NestedText.load("", top_class: Enumerable)
    end
  end

  def test_top_invalid_nil
    assert_raises(NestedText::Errors::UnsupportedTopLevelTypeError) do
      NestedText.load("", top_class: nil)
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
    assert_nil NestedText.load("", top_class: Object)
  end

  def test_empty_whitespace
    assert_nil NestedText.load("  ")
  end

  def test_dict_single_entry
    assert_equal({ "a" => "b" }, NestedText.load("a: b"))
  end

  def test_dict_two_entries
    assert_equal({ "a" => "b", "5" => "7" }, NestedText.load("a: b\n5: 7"))
  end

  def test_dict_three_entries_empty_lines
    assert_equal({ "g" => "f", "5" => "7", "a" => "b" }, NestedText.load("a: b\n5: 7\n  \n\ng: f\n"))
  end

  def test_dict_empty_value
    assert_equal({ "a" => "" }, NestedText.load("a: "))
  end

  def test_dict_nested
    nts = <<~NT
      one:
        two: 3
    NT
    assert_equal({ "one" => { "two" => "3" } }, NestedText.load(nts))
  end

  def test_dict_nested_invalid_indentation
    nts = <<~NT
      one: 1
        two: 2
    NT
    assert_raises(NestedText::Errors::InvalidIndentation) do
      NestedText.load(nts)
    end
  end
end

class DecodeStringTopHashTest < Minitest::Test
  def test_top_hash_dict_empty
    assert_equal({}, NestedText.load("", top_class: Hash))
  end

  def test_top_hash_empty_whitespace
    assert_equal({}, NestedText.load("  ", top_class: Hash))
  end
end

# TODO: class DecodeFile...Test
