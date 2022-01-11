require "stringio"

require "test_helper"

class ParserTest < Minitest::Test
  def test_top_invalid_enumerable
    assert_raises(NestedText::Errors::UnsupportedTopLevelTypeError) do
      NestedText::Parser.new(StringIO.new, Enumerable)
    end
  end

  def test_io_invalid_string
    assert_raises(NestedText::Errors::WrongInputTypeError) do
      NestedText::Parser.new("", Hash)
    end
  end

  def test_invalid_parsed_type
    parser = NestedText::Parser.new(StringIO.new("dummy"), Object)
    parser.stub :parse_any, 1.99 do
      assert_raises(NestedText::Errors::AssertionError) do
        parser.parse
      end
    end
  end
end
