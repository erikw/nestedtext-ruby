require "stringio"

require "test_helper"

class ParserTest < Minitest::Test
  def test_invalid_top_type_initialize
    assert_raises(NestedText::Errors::UnsupportedTopLevelTypeError) do
      NestedText::Parser.new(StringIO.new, Enumerable)
    end
  end

  def test_invalid_top_type_parse
    parser = NestedText::Parser.new(StringIO.new("- dummy"), Object)
    parser.instance_variable_set :@top_class, Enumerable
    assert_raises(NestedText::Errors::UnsupportedTopLevelTypeError) do
      parser.parse
    end
  end

  def test_io_invalid_string
    assert_raises(NestedText::Errors::WrongInputTypeError) do
      NestedText::Parser.new("", Hash)
    end
  end

  def test_invalid_parsed_type
    parser = NestedText::Parser.new(StringIO.new("dummy"), Object)
    # Float is not a valid result type from #parse_any.
    parser.stub :parse_any, 1.99 do
      assert_raises(NestedText::Errors::AssertionError) do
        parser.parse
      end
    end
  end

  def test_invalid_line_tag
    scan_mock = Minitest::Mock.new
    def scan_mock.peek
      line_mock = Minitest::Mock.new
      def line_mock.tag
        :invalid
      end

      def line_mock.nil?
        false
      end
      line_mock
    end

    parser = NestedText::Parser.new(StringIO.new("dummy"), Object)
    parser.instance_variable_set :@line_scanner, scan_mock
    assert_raises(NestedText::Errors::AssertionError) do
      parser.parse
    end
  end

  def test_inline_dict_invalid_parsed_type
    scan_mock = Minitest::Mock.new
    def scan_mock.empty?
      true
    end

    parser = NestedText::Parser.new(StringIO.new("{k: v}"), Object)

    NestedText::InlineScanner.stub :new, scan_mock do
      parser.stub :parse_inline, [] do
        assert_raises(NestedText::Errors::AssertionError) do
          parser.parse
        end
      end
    end
  end
end
