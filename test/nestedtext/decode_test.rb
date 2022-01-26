require "test_helper"

class DecodeStringTopAnyTest < NTTest
  def test_empty
    assert_nil NestedText.load("")
  end

  def test_empty_whitespace
    assert_nil NestedText.load("  ")
  end

  def test_empty_comment
    nts = "#just some\n#comments"
    assert_nil NestedText.load(nts)
  end

  def test_empty_top_any
    assert_nil NestedText.load("", top_class: Object)
  end

  def test_invalid_indentation_first_entry_col0
    assert_raises(ERRORS::InvalidIndentation) do
      NestedText.load(" a: b")
    end
  end

  def test_invalid_line_tag
    assert_raises(ERRORS::LineTagNotDetected) do
      NestedText.load("$ nothing starts with this char")
    end
  end
end

class DecodeStringTopAnyDictTest < NTTest
  def test_dict_single_entry
    nts = "a: b"
    exp = { "a" => "b" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_two_entries
    nts = "a: b\n5: 7"
    exp = { "a" => "b", "5" => "7" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_three_entries_empty_lines
    nts = "a: b\n5: 7\n  \n\ng: f\n"
    exp = { "g" => "f", "5" => "7", "a" => "b" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_empty_value
    nts = "a: "
    exp = { "a" => "" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_empty_value_two
    nts = "a: \nb:"
    exp = { "a" => "", "b" => "" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_key_alignment
    nts = <<~NT
      one        : 1
      twotwo     : 2
      threethree : 3
    NT
    exp = { "one" => "1", "twotwo" => "2", "threethree" => "3" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_nested
    nts = <<~NT
      one:
        two: 3
    NT
    exp = { "one" => { "two" => "3" } }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_nested_invalid_indentation
    nts = <<~NT
      one: 1
        two: 2
    NT
    assert_raises(ERRORS::InvalidIndentation) do
      NestedText.load(nts)
    end
  end

  def test_dict_nested_invalid_indentation_tab
    nts = <<~NT
      key 1:
          \t    key2: this line has tab indentation
    NT
    assert_raises(ERRORS::InvalidIndentationChar) do
      NestedText.load(nts)
    end
  end

  def test_dict_nested_invalid_indentation_non_break_space
    nts = <<~NT
      key:
       > this line has non-breaking space in indentation
    NT
    assert_raises(ERRORS::InvalidIndentationChar) do
      NestedText.load(nts)
    end
  end

  def test_dict_value_of_list
    nts = <<~NT
      key:
          - L1
          - L2
    NT
    exp = { "key" => %w[L1 L2] }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_value_of_multiline_string
    nts = <<~NT
      key:
          > S1
          > S2
    NT
    exp = { "key" => "S1\nS2" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_invalid_type
    nts = <<~NT
      one: two
      - list instead of dict
    NT
    assert_raises(ERRORS::LineTypeExpectedDictItem) do
      NestedText.load(nts)
    end
  end

  def test_dict_valuenextline
    nts = <<~NT
      one:
      two: 2
    NT
    exp = { "one" => "", "two" => "2" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_valuenextline_last_line
    nts = <<~NT
      one:
      # a comment in between here does not hurt! (or empty lines between next)
      two: 2


      three:
    NT
    exp = { "one" => "", "two" => "2", "three" => "" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_single_multiline_key
    nts = <<~NT
      : key:here
      :      still
      : here
          regular: dict
    NT
    exp = { "key:here\n     still\nhere" => { "regular" => "dict" } }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_single_multiline_key_oneline
    nts = <<~NT
      : key but on one line only
          regular: dict
    NT
    exp = { "key but on one line only" => { "regular" => "dict" } }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_single_multiline_key_oneline2
    nts = <<~NT
      : oneline
    NT
    exp = { "oneline" => "" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_legal_spaces
    nts = <<~NT
      k1 : v1
      k2 \t : \tv2
      k3\t:  \tv3
    NT
    exp = { "k1" => "v1", "k2" => "\tv2", "k3" => " \tv3" }
    assert_equal(exp, NestedText.load(nts))
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
    exp = { "key\n one" => { "key-one" => "value1" }, "key\n\ttwo" => { "key-two" => "value2" } }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_multiline_key_list_values
    nts = <<~NT
      : keypt1
      : keypt2
           - l1
           - l2
    NT
    exp = { "keypt1\nkeypt2" => %w[l1 l2] }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_multiline_key_invalid_value
    nts = <<~NT
      : keypt1
      : keypt2
           [inline list here]
    NT
    assert_raises(ERRORS::LineTypeNotExpected) do
      NestedText.load(nts)
    end
  end

  def test_dict_multiline_key_invalid_value_indentation
    nts = <<~NT
      : keypt1
      : keypt2
      - list value, but not further indented
    NT
    assert_raises(ERRORS::ParseMultilineKeyNoValueError) do
      NestedText.load(nts)
    end
  end

  def test_multiline_empty_key_value
    nts = <<~NT
      :
        >
    NT
    exp = { "" => "" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_multiline_empty_key_value_plus_item_after
    nts = <<~NT
      :
        >
      key: value
    NT
    exp = { "" => "", "key" => "value" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_multiline_after_emtpy_dict_value
    nts = <<~NT
      key:
      : key2
         > value2
    NT
    exp = { "key" => "", "key2" => "value2" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_dict_value_invalid_indent_missing
    nts = <<~NT
      dict key:
      - list value
    NT
    assert_raises(ERRORS::LineTypeExpectedDictItem) do
      NestedText.load(nts)
    end
  end

  def test_dict_value_invalid_indent_dedented
    nts = <<~NT
      key1:
          key2: v2
        key3: v3
    NT
    assert_raises(ERRORS::InvalidIndentation) do
      NestedText.load(nts)
    end
  end

  def test_dict_value_invalid_indent_whitespace_value_above
    nts = <<~NT
      key1:#{" "}
          key2: v2
    NT
    assert_raises(ERRORS::InvalidIndentation) do
      NestedText.load(nts)
    end
  end
end

class DecodeStringTopAnyListTest < NTTest
  def test_list_empty
    nts = <<~NT
      -
    NT
    exp = [""]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_list_empty_two
    nts = <<~NT
      -
      -
    NT
    exp = ["", ""]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_list_value_not_indented
    nts = <<~NT
      -
      [not indented]
    NT
    assert_raises(ERRORS::LineTypeExpectedListItem) do
      NestedText.load(nts)
    end
  end

  def test_list_single_item
    nts = <<~NT
      - List  Item\t
    NT
    exp = ["List  Item\t"]
    assert_equal(exp, NestedText.load(nts))
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
    assert_raises(ERRORS::InvalidIndentation) do
      NestedText.load(nts)
    end
  end

  def test_list_invalid_line_type
    nts = <<~NT
      - item here
      : but suddently key item here
    NT
    assert_raises(ERRORS::LineTypeExpectedListItem) do
      NestedText.load(nts)
    end
  end

  def test_list_nested_invalid_indentation_tab
    nts = <<~NT
      key:
       \t    - this line has tab indentation
    NT
    assert_raises(ERRORS::InvalidIndentationChar) do
      NestedText.load(nts)
    end
  end

  def test_list_nested_invalid_linetag
    nts = <<~NT
      - valid line
      $ invalid line
    NT
    assert_raises(ERRORS::LineTagNotDetected) do
      NestedText.load(nts)
    end
  end

  def test_list_error_duplicate_key
    nts = <<~NT
      key: value1
      key: value2
    NT
    assert_raises(ERRORS::DictDuplicateKey) do
      NestedText.load(nts)
    end
  end
end

class DecodeStringTopAnyMultilineStringTest < NTTest
  def test_multistring_single_line
    nts = <<~NT
      > just this line\t
    NT
    exp = "just this line\t"
    assert_equal(exp, NestedText.load(nts))
  end

  def test_multistring_single_line_empty
    nts = <<~NT
      >
    NT
    exp = ""
    assert_equal(exp, NestedText.load(nts))
  end

  def test_multistring_multiple_line
    nts = <<~NT
      > L1
      > \tL2
      >   L3
    NT
    exp = "L1\n\tL2\n  L3"
    assert_equal(exp, NestedText.load(nts))
  end

  def test_multistring_multiple_line_empty
    nts = <<~NT
      >
      >
      >
    NT
    exp = "\n\n"
    assert_equal(exp, NestedText.load(nts))
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
    exp = "L1\n\nL3\n\n\nL6"
    assert_equal(exp, NestedText.load(nts))
  end

  def test_multistring_invalid_indentation
    nts = <<~NT
      > L1
        > L2
    NT
    assert_raises(ERRORS::InvalidIndentation) do
      NestedText.load(nts)
    end
  end

  def test_multistring_invalid_line_type
    nts = <<~NT
      > multiline here
      : but suddently key item here
    NT
    assert_raises(ERRORS::LineTypeNotExpected) do
      NestedText.load(nts)
    end
  end

  def test_dict_nested_invalid_indentation_tab
    nts = <<~NT
      key:
          \t    > multiline
                > string
    NT
    assert_raises(ERRORS::InvalidIndentationChar) do
      NestedText.load(nts)
    end
  end
end

class DecodeStringTopAnyInlineDictTest < NTTest
  def test_inline_dict_empty
    assert_equal({}, NestedText.load("{}"))
  end

  def test_inline_dict_invalid_empty_whitespace
    assert_raises(ERRORS::InlineDictKeySyntaxError) do
      NestedText.load("{ }")
    end
  end

  def test_inline_dict_invalid_empty_values
    assert_raises(ERRORS::InlineDictKeySyntaxError) do
      NestedText.load("{,}")
    end
  end

  def test_inline_dict_invalid_missing_value
    assert_raises(ERRORS::InlineMissingValue) do
      NestedText.load("{a:1,}")
    end
  end

  def test_inline_dict_single_entry
    nts = "{a:1}"
    exp = { "a" => "1" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_single_entry_empty_key
    nts = "{:1}"
    exp = { "" => "1" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_single_entry_empty_valuue
    assert_equal({ "1" => "" }, NestedText.load("{1:}"))
  end

  def test_inline_dict_single_entry_empty_key_value
    nts = "{:}"
    exp = { "" => "" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_multiple_entry
    nts = "{a:1, b : 2, c :3}"
    exp = { "a" => "1", "b" => "2", "c" => "3" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_multiple_entry_empty_values
    nts = "{a:, b : , c:}"
    exp = { "a" => "", "b" => "", "c" => "" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_nested_dict_first
    nts = "{a: {b : 1}, c: 2}"
    exp = { "a" => { "b" => "1" }, "c" => "2" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_nested_dict_between
    nts = "{a: 1, b: {c : 2}, d: 3}"
    exp = { "a" => "1", "b" => { "c" => "2" }, "d" => "3" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_nested_dict_last
    nts = "{a:1, b: {c : 2}}"
    exp = { "a" => "1", "b" => { "c" => "2" } }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_nested_list
    nts = "{a:1, b: [l1, l2] }"
    exp = { "a" => "1", "b" => %w[l1 l2] }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_space_between_dict_and_comma
    nts = "{ a : { b : 1 } , c : 2 }   "
    exp = { "a" => { "b" => "1" }, "c" => "2" }
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_dict_invalid_wrong_closing_bracket
    nts = "{a: 1, b: 2]"
    assert_raises(ERRORS::InlineDictSyntaxError) do
      NestedText.load(nts)
    end
  end

  def test_inline_dict_invalid_missing_closing_bracket
    nts = "{a: 1, b: 2"
    assert_raises(ERRORS::InlineNoClosingDelimiter) do
      NestedText.load(nts)
    end
  end

  def test_inline_dict_invalid_inline_string
    nts = "{a: 1:b"
    assert_raises(ERRORS::InlineNoClosingDelimiter) do
      NestedText.load(nts)
    end
  end

  def test_inline_dict_extra_char
    nts = "{a: 1}x"
    assert_raises(ERRORS::InlineExtraCharactersAfterDelimiter) do
      NestedText.load(nts)
    end
  end

  def test_inline_dict_extra_chars
    nts = "{a: 1}extra"
    assert_raises(ERRORS::InlineExtraCharactersAfterDelimiter) do
      NestedText.load(nts)
    end
  end

  def test_inline_dict_incomplete_key
    nts = "{key"
    assert_raises(ERRORS::InlineNoClosingDelimiter) do
      NestedText.load(nts)
    end
  end
end

class DecodeStringTopAnyInlineListTest < NTTest
  def test_inline_list_empty
    nts = "[]"
    exp = []
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_empty_string
    nts = "[ ]"
    exp = [""]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_single_item
    nts = "[item]"
    exp = ["item"]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_single_plus_empty_item
    nts = "[item,]"
    exp = ["item", ""]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_single_plus_empty_items
    nts = "[item,,]"
    exp = ["item", "", ""]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_whitespace_tabs
    nts = "[1, 2 ,\t3\t, \t 4,\t 5]"
    exp = %w[1 2 3 4 5]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_multiple_item
    nts = "[1,2 ,3, a  ,  b]"
    exp = %w[1 2 3 a b]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_nested_first
    nts = "[[1, 2], 3]"
    exp = [%w[1 2], "3"]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_nested_second
    nts = "[1, [2, 3]]"
    exp = ["1", %w[2 3]]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_nested_multiple_singles
    nts = "[[1], [2], [3]]"
    exp = [["1"], ["2"], ["3"]]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_nested_multiple_mixed
    nts = "[[1, 2], 3, [4, 5], 6]"
    exp = [%w[1 2], "3", %w[4 5], "6"]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_nested_nested
    nts = "[[[1], 2], 3]"
    exp = [[["1"], "2"], "3"]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_nested_dict
    nts = "[1, {a: 2, b: 3}]"
    exp = ["1", { "a" => "2", "b" => "3" }]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_nested_dict_nested_list
    nts = "[1, {a: [ 2, 3 ] } ]"
    exp = ["1", { "a" => %w[2 3] }]
    assert_equal(exp, NestedText.load(nts))
  end

  def test_inline_list_invalid_wrong_closing_bracket
    nts = "[1, 2}"
    assert_raises(ERRORS::InlineListSyntaxError) do
      NestedText.load(nts)
    end
  end

  def test_inline_list_no_closing_bracket_empty
    nts = "[,"
    assert_raises(ERRORS::InlineNoClosingDelimiter) do
      NestedText.load(nts)
    end
  end

  def test_inline_list_no_closing_bracket_items
    nts = "[1, 2"
    assert_raises(ERRORS::InlineNoClosingDelimiter) do
      NestedText.load(nts)
    end
  end

  def test_inline_list_extra_chars
    nts = "[a, b]extra"
    assert_raises(ERRORS::InlineExtraCharactersAfterDelimiter) do
      NestedText.load(nts)
    end
  end

  def test_inline_list_missing_value
    nts = "[a, }]"
    assert_raises(ERRORS::InlineMissingValue) do
      NestedText.load(nts)
    end
  end
end

class DecodeStringTopTest < NTTest
  def test_top_invalid_enumerable
    assert_raises(ERRORS::UnsupportedTopLevelTypeError) do
      NestedText.load("", top_class: Enumerable)
    end
  end

  def test_top_invalid_nil
    assert_raises(ERRORS::UnsupportedTopLevelTypeError) do
      NestedText.load("", top_class: nil)
    end
  end

  def test_input_invalid_array
    assert_raises(ERRORS::WrongInputTypeError) do
      NestedText.load([])
    end
  end

  def test_input_invalid_hash
    assert_raises(ERRORS::WrongInputTypeError) do
      NestedText.load({})
    end
  end

  def test_top_hash_but_is_array
    nts = "- l1"
    assert_raises(ERRORS::TopLevelTypeMismatchParsedType) do
      NestedText.load(nts, top_class: Hash)
    end
  end

  def test_top_array_but_is_hash
    nts = "k: v"
    assert_raises(ERRORS::TopLevelTypeMismatchParsedType) do
      NestedText.load(nts, top_class: Array)
    end
  end
end

class DecodeStringTopHashTest < NTTest
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
    assert_raises(ERRORS::TopLevelTypeMismatchParsedType) do
      NestedText.load(nts, top_class: Hash)
    end
  end
end

class DecodeStringTopArrayTest < NTTest
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
    assert_raises(ERRORS::TopLevelTypeMismatchParsedType) do
      NestedText.load(nts, top_class: Array)
    end
  end
end

class DecodeStringTopArrayTest < NTTest
  def test_top_multilinestring_empty
    nts = "      "
    exp = ""
    assert_equal(exp, NestedText.load(nts, top_class: String))
  end

  def test_top_multilinestring_multiline
    nts = "> line 1\n> line 2"
    exp = "line 1\nline 2"
    assert_equal(exp, NestedText.load(nts, top_class: String))
  end

  def test_top_multilinestring_invalid_actual
    nts = <<~NT
      - this list item will not be expected
    NT
    assert_raises(ERRORS::TopLevelTypeMismatchParsedType) do
      NestedText.load(nts, top_class: String)
    end
  end
end

class DecodeFileTest < NTTest
  FIXTURE_PATH = "test/fixtures"

  def test_load_file_hash_dict_nested
    ntf = FIXTURE_PATH + "/1.nt"
    exp = { "one" => { "two" => "3" } }
    assert_equal(exp, NestedText.load_file(ntf, top_class: Hash))
  end

  def test_load_file_nested_multiple
    ntf = FIXTURE_PATH + "/2.nt"
    exp = { "a" => { "b" => "1" }, "c" => "2", "d" => { "e" => "3" }, "f" => "" }
    assert_equal(exp, NestedText.load_file(ntf, top_class: Hash))
  end

  def test_load_file_invalid_filename_nil
    assert_raises(ERRORS::WrongInputTypeError) do
      NestedText.load_file(nil)
    end
  end

  def test_load_file_invalid_filename_array
    assert_raises(ERRORS::WrongInputTypeError) do
      NestedText.load_file([])
    end
  end
end

class NoNTCreateClass; end

class DecodeCustomClassTest < NTTest
  class NotInScope; end

  def test_custom_class_no_nt_creat_method
    nts = <<~NT
      __nestedtext_class__: NoNTCreateClass
      data: dummy
    NT

    assert_raises(ERRORS::ParseCustomClassNoCreateMethod) do
      NestedText.load(nts)
    end
  end

  # TODO: test this with real client code outside this repo, to ensure how to handle this. Is the solution to make a missing require 'NotInScope' if the class is in this module but not yet loaded in to the program? Translte to unit test here after experimentation.
  def test_custom_class_not_in_scope
    nts = <<~NT
      __nestedtext_class__: NotInScope
      data: dummy
    NT

    assert_raises(ERRORS::ParseCustomClassNotFound) do
      NestedText.load(nts)
    end
  end

  def test_custom_class_no_decode_strict_true
    nts = <<~NT.chomp
      __nestedtext_class__: DummyClass
      data: dummydata
    NT
    exp = { "__nestedtext_class__" => "DummyClass", "data" => "dummydata" }
    assert_equal(exp, NestedText.load(nts, strict: true))
  end
end
