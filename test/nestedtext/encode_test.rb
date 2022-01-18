require "test_helper"

require_relative "../encode_test_helpers"

class EncodeTest < Minitest::Test
  def test_nil
    obj = nil
    exp = ""
    assert_equal exp, NestedText.dump(obj)
  end

  # TODO: test cycle detection.
  # Using scopes like nypy's "with Keys()", but Ruby's blocks with ensure? https://stackoverflow.com/a/3875832/265508
  # def test_cyclic_references
  # a = []
  # b = [a]
  # a << b
  # assert_raises(NestedText::Errors::EncodingCyclicReferencesDetected) do
  # NestedText.dump(a)
  # end
  # end
end

class EncodeArrayTest < Minitest::Test
  def test_array_empty
    assert_equal "[]", NestedText.dump([])
  end

  def test_array_nil
    assert_equal "-", NestedText.dump([nil])
  end

  def test_array_empty_string
    assert_equal "-", NestedText.dump([""])
  end

  def test_array_whitespace_string
    assert_equal "-  ", NestedText.dump([" "])
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

  def test_array_multiple_nil
    obj = [nil, "a", nil]
    exp = <<~NT.chomp
      -
      - a
      -
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

  def test_array_method_to_nt
    obj = ["an item here"]
    exp = <<~NT.chomp
      - an item here
    NT
    assert_equal exp, obj.to_nt
  end
end

# TODO: test symbols in array/hash: how encode them?
# TODO test arrays combined with hash
# TODO test multi-line key variations according to the spec
# TODO test nested dicts (with indentation)
# TODO test multiple items, and with multiline keys and multiline values
class EncodeHashTest < Minitest::Test
  def test_hash_empty
    assert_equal "{}", NestedText.dump({})
  end

  def test_hash_single_nil_value
    obj = { "key" => nil }
    exp = <<~NT.chomp
      key:
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_empty_value
    obj = { "key" => "" }
    exp = <<~NT.chomp
      key:
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_whitespace_value
    obj = { "key" => " " }
    exp = <<~NT.chomp
      key:#{"  "}
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_empty_key
    obj = { "" => "value" }
    exp = <<~NT.chomp
      :
          > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  # TODO: test empty key variations
  def test_hash_single_empty_key_and_value
    obj = { "" => "" }
    exp = <<~NT.chomp
      :
          >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_whitespace_key_and_value
    obj = { " " => " " }
    exp = <<~NT.chomp
      :#{"  "}
          >#{"  "}
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_item
    obj = { "key" => "value" }
    exp = <<~NT.chomp
      key: value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key
    obj = { "two line\n key" => "value" }
    exp = <<~NT.chomp
      : two line
      :  key
          > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_empty_value
    obj = { "k1\nk2" => "" }
    exp = <<~NT.chomp
      : k1
      : k2
          >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_whitespace_value
    obj = { "k1\nk2" => " " }
    exp = <<~NT.chomp
      : k1
      : k2
          >#{"  "}
    NT
    assert_equal exp, NestedText.dump(obj)
  end
  # TODO: more advanced multiline key test
end

class EncodeStringTest < Minitest::Test
  def test_string_empty
    assert_equal ">", NestedText.dump("")
  end

  def test_string_whitespace
    assert_equal ">  ", NestedText.dump(" ")
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

  def test_string_multiline_trailing_linefeed
    obj = "multi-line\nwith trailing line\n"
    exp = <<~NT.chomp
      > multi-line
      > with trailing line
      >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_multiline_multi_trailing_linefeed
    obj = "multi-line\nwith trailing line\n\t\n \n\n"
    exp = <<~NT.chomp
      > multi-line
      > with trailing line
      > \t
      >#{"  "}
      >
      >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_multiline_preceeding_linefeed
    obj = "\nempty line before and after\n"
    exp = <<~NT.chomp
      >
      > empty line before and after
      >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_method_to_nt
    obj = "multi-line\nstring"
    exp = <<~NT.chomp
      > multi-line
      > string
    NT
    assert_equal exp, obj.to_nt
  end
end

class EncodeCustomClassTest < Minitest::Test
  def test_custom_class_nested
    outer = Outer.new("a", "b", Inner.new("c"))
    obj = [outer]
    exp = <<~NT.chomp
      -
          - class__Outer
          -
              - a
              - b
              -
                  - class__Inner
                  -
                      - c
    NT
    dumped = NestedText.dump(obj, strict: false)
    assert_equal exp, dumped

    loaded = NestedText.load(dumped, strict: false)
    assert_equal obj, loaded
  end

  def test_custom_class_nested_indented
    obj = Outer.new("a", "b", Inner.new("c"))
    exp = <<~NT.chomp
      - class__Outer
      -
        - a
        - b
        -
          - class__Inner
          -
            - c
    NT
    dumped = NestedText.dump(obj, indentation: 2, strict: false)
    assert_equal exp, dumped

    loaded = NestedText.load(dumped, strict: false)
    assert_equal obj, loaded
  end

  def test_custom_class_method_to_nt
    obj = Inner.new("a")
    exp = <<~NT.chomp
      - class__Inner
      -
        - a
    NT
    dumped = obj.to_nt(indentation: 2)
    assert_equal exp, dumped
  end

  def test_custom_class_linked_list
    obj = Node.from_enum(%w[a b c])
    exp = <<~NT.chomp
      - class__Node
      -
          - a
          -
              - class__Node
              -
                  - b
                  -
                      - class__Node
                      -
                          - c
                          -
                              - class__nil
                              -
    NT
    dumped = NestedText.dump(obj, strict: false)
    assert_equal exp, dumped

    loaded = NestedText.load(dumped, strict: false)
    assert_equal obj, loaded
  end

  def test_custom_class_not_encodeable
    obj = NotNTEncodable.new
    assert_raises(NestedText::Errors::DumpUnsupportedTypeError) do
      NestedText.dump(obj)
    end
  end
end
