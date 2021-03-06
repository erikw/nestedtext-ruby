# frozen_string_literal: true

require 'stringio'

require 'test_helper'

class ParserTest < NTTest
  def test_invalid_top_type_initialize
    assert_raises(ERRORS::UnsupportedTopLevelTypeError) do
      PARSER.new(StringIO.new, Enumerable)
    end
  end

  def test_invalid_top_type_parse
    parser = PARSER.new(StringIO.new('- dummy'), Object)
    parser.instance_variable_set :@top_class, Enumerable
    assert_raises(ERRORS::UnsupportedTopLevelTypeError) do
      parser.parse
    end
  end

  def test_io_invalid_string
    assert_raises(ERRORS::WrongInputTypeError) do
      PARSER.new('', Hash)
    end
  end

  def test_invalid_parsed_type
    parser = PARSER.new(StringIO.new('dummy'), Object, strict: true)
    # Float is not a valid result type from #parse_any.
    parser.stub :parse_any, 1.99 do
      assert_raises(ERRORS::AssertionError) do
        parser.parse
      end
    end
  end

  def test_invalid_line_tag
    scan_mock = Minitest::Mock.new
    def scan_mock.peek
      line_mock = Minitest::Mock.new
      def line_mock.tag = :invalid
      def line_mock.nil? = false
      line_mock
    end

    parser = PARSER.new(StringIO.new('dummy'), Object)
    parser.instance_variable_set :@line_scanner, scan_mock
    assert_raises(ERRORS::AssertionError) do
      parser.parse
    end
  end

  def test_inline_dict_invalid_parsed_type
    inline_parser_mock = Minitest::Mock.new
    def inline_parser_mock.parse
      []
    end

    parser = PARSER.new(StringIO.new('{k: v}'), Object)
    INLINE_PARSER.stub :new, inline_parser_mock do
      assert_raises(ERRORS::AssertionError) do
        parser.parse
      end
    end
  end

  def test_inline_list_invalid_parsed_type
    inline_parser_mock = Minitest::Mock.new
    def inline_parser_mock.parse
      {}
    end

    parser = PARSER.new(StringIO.new('[i1, i2]'), Object)
    INLINE_PARSER.stub :new, inline_parser_mock do
      assert_raises(ERRORS::AssertionError) do
        parser.parse
      end
    end
  end
end
