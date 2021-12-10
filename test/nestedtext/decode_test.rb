require "test_helper"

class DecodeStringTopAnyTest < Minitest::Test
  def test_empty
    assert_nil NestedText.load("")
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
