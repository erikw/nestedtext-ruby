require "stringio"

require "test_helper"

class LineScannerTest < Minitest::Test
  def test_empty
    scanner = NestedText::LineScanner.new(StringIO.new("# comment\n#comment"))
    assert scanner.empty?
  end

  def test_reading_when_empty
    ntstring = "- single item"
    scanner = NestedText::LineScanner.new(StringIO.new(ntstring))
    refute scanner.empty?
    line = scanner.read_next
    assert_equal ntstring, line.content

    assert scanner.empty?
    assert_raises(NestedText::Errors::LineScannerIsEmpty) do
      scanner.read_next
    end
  end
end

class InlineScannerTest < Minitest::Test
  def test_empty
    line = NestedText::Line.new("", 0, nil)
    scanner = NestedText::InlineScanner.new(line)
    assert scanner.empty?
  end

  def test_reading_when_empty
    line = NestedText::Line.new("1", 0, nil)
    scanner = NestedText::InlineScanner.new(line)
    refute scanner.empty?
    char = scanner.read_next
    assert_equal line.content, char

    assert scanner.empty?
    assert_raises(NestedText::Errors::InlineScannerIsEmpty) do
      scanner.read_next
    end
  end
end

class LineTest < Minitest::Test
  def test_to_s
    content = "string content"
    line = NestedText::Line.new(content, 0, nil)
    repr = line.to_s
    assert repr.include? content
  end

  def test_invalid_tag
    line = NestedText::Line.new("", 0, nil)
    assert_raises(NestedText::Errors::LineTagUnknown) do
      line.tag = :not_allowed
    end
  end
end
