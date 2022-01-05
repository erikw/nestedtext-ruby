require "test_helper"

class DecodeStringTopAnyTest < Minitest::Test
  def test_empty
    assert_nil NestedText.load("")
  end

  def test_empty_whitespace
    assert_nil NestedText.load("  ")
  end

  def test_empty_comment
    assert_nil NestedText.load("#just some\n#comments")
  end

  def test_empty_top_any
    assert_nil NestedText.load("", top_class: Object)
  end

  def test_invalid_indentation_first_entry_col0
    assert_raises(NestedText::Errors::InvalidIndentation) do
      NestedText.load(" a: b")
    end
  end
end

class DecodeStringTopAnyDictTest < Minitest::Test
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

  def test_dict_empty_value_two
    assert_equal({ "a" => "", "b" => "" }, NestedText.load("a: \nb:"))
  end

  def test_dict_key_alignment
    nts = <<~NT
      one        : 1
      twotwo     : 2
      threethree : 3
    NT
    assert_equal({ "one" => "1", "twotwo" => "2", "threethree" => "3" }, NestedText.load(nts))
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

  def test_dict_value_of_list
    nts = <<~NT
      key:
          - L1
          - L2
    NT
    assert_equal({ "key" => %w[L1 L2] }, NestedText.load(nts))
  end

  def test_dict_value_of_multiline_string
    nts = <<~NT
      key:
          > S1
          > S2
    NT
    assert_equal({ "key" => "S1\nS2" }, NestedText.load(nts))
  end

  def test_dict_invalid_type
    nts = <<~NT
      one: two
      - list instead of dict
    NT
    assert_raises(NestedText::Errors::LineTypeNotExpected) do
      NestedText.load(nts)
    end
  end

  def test_dict_valuenextline
    nts = <<~NT
      one:
      two: 2
    NT
    assert_equal({ "one" => "", "two" => "2" }, NestedText.load(nts))
  end

  def test_dict_valuenextline_last_line
    nts = <<~NT
      one:
      # a comment in between here does not hurt! (or empty lines between next)
      two: 2


      three:
    NT
    assert_equal({ "one" => "", "two" => "2", "three" => "" }, NestedText.load(nts))
  end

  def test_dict_single_multiline_key
    nts = <<~NT
      : key:here
      :      still
      : here
          regular: dict
    NT
    assert_equal({ "key:here\n     still\nhere" => { "regular" => "dict" } }, NestedText.load(nts))
  end

  def test_dict_single_multiline_key_oneline
    nts = <<~NT
      : key but on one line only
          regular: dict
    NT
    assert_equal({ "key but on one line only" => { "regular" => "dict" } }, NestedText.load(nts))
  end

  def test_dict_single_multiline_key_oneline2
    nts = <<~NT
      : oneline
    NT
    assert_equal({ "oneline" => "" }, NestedText.load(nts))
  end

  def test_dict_two_multiline_keys
    nts = <<~NT
      : key
      :  one
        key-one: value1
      : key
      : \ttwo
        key-two: value2
    NT
    assert_equal({ "key\n one" => { "key-one" => "value1" }, "key\n\ttwo" => { "key-two" => "value2" } },
                 NestedText.load(nts))
  end

  def test_dict_single_multiline_key_list_values
    nts = <<~NT
      : keypt1
      : keypt2
           - l1
           - l2
    NT
    assert_equal({ "keypt1\nkeypt2" => %w[l1 l2] }, NestedText.load(nts))
  end

  def test_dict_single_multiline_key_invalid_value
    nts = <<~NT
      : keypt1
      : keypt2
           [inline list here]
    NT
    assert_raises(NestedText::Errors::LineTypeNotExpected) do
      NestedText.load(nts)
    end
  end

  def test_dict_single_multiline_key_invalid_value_indentation
    nts = <<~NT
      : keypt1
      : keypt2
      - list value, but not further indented
    NT
    assert_raises(NestedText::Errors::MultilineKeyNoValue) do
      NestedText.load(nts)
    end
  end
end

class DecodeStringTopAnyListTest < Minitest::Test
  def test_list_empty
    nts = <<~NT
      -
    NT
    assert_equal([""], NestedText.load(nts))
  end

  def test_list_empty_two
    nts = <<~NT
      -
      -
    NT
    assert_equal(["", ""], NestedText.load(nts))
  end

  def test_list_single_item
    nts = <<~NT
      - List  Item\t
    NT
    assert_equal(["List  Item\t"], NestedText.load(nts))
  end

  def test_list_multiple_items
    nts = <<~NT
      - List  Item\t
      - item2
      -  \t
      - item three
    NT
    exp = ["List  Item\t", "item2", " \t", "item three"]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_list_nested_list
    nts = <<~NT
      - item1
      -
        - item2
        - item3
    NT
    exp = ["item1", %w[item2 item3]]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_list_nested_dict
    nts = <<~NT
      - item1
      -
        key1 : value1
        key2 : value2
    NT
    exp = ["item1", { "key1" => "value1", "key2" => "value2" }]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_list_nested_multiple
    nts = <<~NT
      -
        - litem1
        - litem2
      -
        key1 : value1
        key2 : value2
      -
        > some multi-line
        > string here
      - litem3
    NT
    exp = [%w[litem1 litem2], { "key1" => "value1", "key2" => "value2" }, "some multi-line\nstring here", "litem3"]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_list_invalid_indentation
    nts = <<~NT
      - L1
        - L2
    NT
    assert_raises(NestedText::Errors::InvalidIndentation) do
      NestedText.load(nts)
    end
  end

  def test_list_invalid_line_type
    nts = <<~NT
      - item here
      : but suddently key item here
    NT
    assert_raises(NestedText::Errors::LineTypeNotExpected) do
      NestedText.load(nts)
    end
  end
end

class DecodeStringTopAnyMultilineStringTest < Minitest::Test
  def test_multistring_single_line
    nts = <<~NT
      > just this line\t
    NT
    assert_equal("just this line\t", NestedText.load(nts))
  end

  def test_multistring_single_line_empty
    nts = <<~NT
      >
    NT
    assert_equal("", NestedText.load(nts))
  end

  def test_multistring_multiple_line
    nts = <<~NT
      > L1
      > \tL2
      >   L3
    NT
    assert_equal("L1\n\tL2\n  L3", NestedText.load(nts))
  end

  def test_multistring_multiple_line_empty
    nts = <<~NT
      >
      >
      >
    NT
    assert_equal("\n\n", NestedText.load(nts))
  end

  def test_multistring_multiple_line_with_empty_between
    nts = <<~NT
      > L1

      >


      > L3
      >
      >
      > L6
    NT
    assert_equal("L1\n\nL3\n\n\nL6", NestedText.load(nts))
  end

  def test_multistring_invalid_indentation
    nts = <<~NT
      > L1
        > L2
    NT
    assert_raises(NestedText::Errors::InvalidIndentation) do
      NestedText.load(nts)
    end
  end

  def test_multistring_invalid_line_type
    nts = <<~NT
      > multiline here
      : but suddently key item here
    NT
    assert_raises(NestedText::Errors::LineTypeNotExpected) do
      NestedText.load(nts)
    end
  end
end

class DecodeStringTopAnyInlineDictTest < Minitest::Test
  def test_inline_dict_empty
    assert_equal({}, NestedText.load("{}"))
  end

  def test_inline_dict_invalid_empty_whitespace
    assert_raises(NestedText::Errors::InlineDictKeySyntaxError) do
      NestedText.load("{ }")
    end
  end

  def test_inline_dict_invalid_empty_values
    assert_raises(NestedText::Errors::InlineDictKeySyntaxError) do
      NestedText.load("{,}")
    end
  end

  def test_inline_dict_invalid_missing_value
    assert_raises(NestedText::Errors::InlineDictKeySyntaxError) do
      NestedText.load("{a:1,}")
    end
  end

  def test_inline_dict_single_entry
    assert_equal({ "a" => "1" }, NestedText.load("{a:1}"))
  end

  def test_inline_dict_single_entry_empty_key
    assert_equal({ "" => "1" }, NestedText.load("{:1}"))
  end

  def test_inline_dict_single_entry_empty_valuue
    assert_equal({ "1" => "" }, NestedText.load("{1:}"))
  end

  def test_inline_dict_single_entry_empty_key_value
    assert_equal({ "" => "" }, NestedText.load("{:}"))
  end

  def test_inline_dict_multiple_entry
    assert_equal({ "a" => "1", "b" => "2", "c" => "3" }, NestedText.load("{a:1, b : 2, c :3}"))
  end

  def test_inline_dict_multiple_entry_empty_values
    assert_equal({ "a" => "", "b" => "", "c" => "" }, NestedText.load("{a:, b : , c:}"))
  end

  def test_inline_dict_nested_dict_first
    assert_equal({ "a" => { "b" => "1" }, "c" => "2" }, NestedText.load("{a: {b : 1}, c: 2}"))
  end

  def test_inline_dict_nested_dict_between
    assert_equal({ "a" => "1",  "b" => { "c" => "2" }, "d" => "3" }, NestedText.load("{a: 1, b: {c : 2}, d: 3}"))
  end

  def test_inline_dict_nested_dict_last
    assert_equal({ "a" => "1", "b" => { "c" => "2" } }, NestedText.load("{a:1, b: {c : 2}}"))
  end

  def test_inline_dict_nested_list
    assert_equal({ "a" => "1", "b" => %w[l1 l2] }, NestedText.load("{a:1, b: [l1, l2] }"))
  end

  def test_inline_dict_invalid_wrong_closing_bracket
    assert_raises(NestedText::Errors::InlineDictSyntaxError) do
      NestedText.load("{a: 1, b: 2]")
    end
  end

  def test_inline_dict_invalid_missing_closing_bracket
    assert_raises(NestedText::Error) do
      NestedText.load("{a: 1, b: 2")
    end
  end

  def test_inline_dict_invalid_inline_string
    assert_raises(NestedText::Error) do
      NestedText.load("{a: 1:b")
    end
  end
end

class DecodeStringTopAnyInlineListTest < Minitest::Test
  def test_inline_list_empty
    assert_equal([], NestedText.load("[]"))
  end

  def test_inline_list_empty_string
    assert_equal([""], NestedText.load("[ ]"))
  end

  def test_inline_list_single_item
    assert_equal(["item"], NestedText.load("[item]"))
  end

  def test_inline_list_single_plus_empty_item
    assert_equal(["item", ""], NestedText.load("[item,]"))
  end

  def test_inline_list_single_plus_empty_items
    assert_equal(["item", "", ""], NestedText.load("[item,,]"))
  end

  def test_inline_list_multiple_item
    assert_equal(%w[1 2 3 a b], NestedText.load("[1,2 ,3, a  ,  b]"))
  end

  def test_inline_list_nested_first
    assert_equal([%w[1 2], "3"], NestedText.load("[[1, 2], 3]"))
  end

  def test_inline_list_nested_second
    assert_equal(["1", %w[2 3]], NestedText.load("[1, [2, 3]]"))
  end

  def test_inline_list_nested_multiple_singles
    assert_equal([["1"], ["2"], ["3"]], NestedText.load("[[1], [2], [3]]"))
  end

  def test_inline_list_nested_multiple_mixed
    assert_equal([%w[1 2], "3", %w[4 5], "6"], NestedText.load("[[1, 2], 3, [4, 5], 6]"))
  end

  def test_inline_list_nested_nested
    assert_equal([[["1"], "2"], "3"], NestedText.load("[[[1], 2], 3]"))
  end

  def test_inline_list_nested_dict
    assert_equal(["1", { "a" => "2", "b" => "3" }], NestedText.load("[1, {a: 2, b: 3}]"))
  end

  def test_inline_list_nested_dict_nested_list
    assert_equal(["1", { "a" => %w[2 3] }], NestedText.load("[1, {a: [ 2, 3 ] } ]"))
  end

  def test_inline_list_invalid_wrong_closing_bracket
    assert_raises(NestedText::Errors::InlineListSyntaxError) do
      NestedText.load("[1, 2}")
    end
  end

  def test_inline_list_invalid_missing_closing_bracket
    assert_raises(NestedText::Error) do
      NestedText.load("[1, 2")
    end
  end
end

class DecodeStringTopTest < Minitest::Test
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

class DecodeStringTopHashTest < Minitest::Test
  def test_top_hash_empty
    assert_equal({}, NestedText.load("", top_class: Hash))
  end

  def test_top_hash_empty_whitespace
    assert_equal({}, NestedText.load("  ", top_class: Hash))
  end

  def test_top_hash_invalid_actual
    nts = <<~NT
      - it's a list!
    NT
    assert_raises(NestedText::Errors::TopLevelTypeMismatchParsedType) do
      NestedText.load(nts, top_class: Hash)
    end
  end
end

class DecodeStringTopArrayTest < Minitest::Test
  def test_top_array_empty
    assert_equal([], NestedText.load("", top_class: Array))
  end

  def test_top_array_empty_whitespace
    assert_equal([], NestedText.load("  ", top_class: Array))
  end

  def test_top_array_invalid_actual
    nts = <<~NT
      this is a : dict
    NT
    assert_raises(NestedText::Errors::TopLevelTypeMismatchParsedType) do
      NestedText.load(nts, top_class: Array)
    end
  end
end

class DecodeStringTopArrayTest < Minitest::Test
  def test_top_multilinestring_empty
    assert_equal("", NestedText.load("      ", top_class: String))
  end

  def test_top_multilinestring_multiline
    assert_equal("line 1\nline 2", NestedText.load("> line 1\n> line 2", top_class: String))
  end

  def test_top_multilinestring_invalid_actual
    nts = <<~NT
      - this list item will not be expected
    NT
    assert_raises(NestedText::Errors::TopLevelTypeMismatchParsedType) do
      NestedText.load(nts, top_class: String)
    end
  end
end

class DecodeFileTest < Minitest::Test
  FIXTURE_PATH = "test/fixtures"

  def test_top_hash_dict_nested
    assert_equal({ "one" => { "two" => "3" } }, NestedText.load_file(FIXTURE_PATH + "/1.nt", top_class: Hash))
  end

  def test_dict_nested_multiple
    assert_equal({ "a" => { "b" => "1" }, "c" => "2", "d" => { "e" => "3" }, "f" => "" },
                 NestedText.load_file(FIXTURE_PATH + "/2.nt", top_class: Hash))
  end
end
