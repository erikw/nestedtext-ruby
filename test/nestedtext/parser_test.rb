require "stringio"

require "test_helper"

class ParserTest < Minitest::Test
  def test_top_invalid_enumerable
    assert_raises(NestedText::Errors::UnsupportedTopLevelTypeError) do
      NestedText::Parser.new(StringIO.new, Enumerable)
    end
  end
end
