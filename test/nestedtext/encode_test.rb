require "test_helper"

require_relative "../encode_test_helpers"

class EncodeTest < Minitest::Test
  def test_empty
    assert_nil NestedText.load("")
  end
end

class EncodeArrayTest < Minitest::Test
  def test_array_empty
    assert_equal "", NestedText.dump([])
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
end

# TODO: test symbols in array/hash: how encode them?
class EncodeHashTest < Minitest::Test
end

class EncodeStringTest < Minitest::Test
  def test_string_empty
    assert_equal ">", NestedText.dump("")
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
end

# TODO: test custom object and with custom indentation
class EncodeToStingCustomClassTest < Minitest::Test
  def test_custom_class_nested
    outer = Outer.new("a", "b", "c")
    obj = [[outer]]
    exp = <<~NT.chomp
      -
          -
              - class__Outer
              -
                  - a
                  - b
                  - c
    NT
    dumped = NestedText.dump(obj)
    assert_equal exp, dumped

    loaded = NestedText.load(dumped)
    assert_equal obj, loaded
  end

  # def test_custom_class_linked_list
  # llist = Node.from_enum(%w[a b c]) # TODO: what if containting integers?
  # require "pry"
  # binding.pry
  # obj = [[outer]]
  # exp = <<~NT.chomp
  #-
  #-
  #- class__Outer
  #-
  #- a
  #- b
  #- c
  # NT
  # dumped = NestedText.dump(obj)
  # assert_equal exp, dumped

  ## loaded = NestedText.load(dumped)
  ## assert_equal obj, loaded
  # end
end
