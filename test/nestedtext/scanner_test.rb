require "stringio"

require "test_helper"

class LineScannerTest < NTTest
  def test_empty
    scanner = LINE_SCANNER.new(StringIO.new("# comment\n#comment"))
    assert scanner.empty?
  end

  def test_reading_when_empty
    ntstring = "- single item"
    scanner = LINE_SCANNER.new(StringIO.new(ntstring))
    refute scanner.empty?
    line = scanner.read_next
    assert_equal ntstring, line.content

    assert scanner.empty?
    assert_raises(ERRORS::LineScannerIsEmpty) do
      scanner.read_next
    end
  end
end

class InlineScannerTest < NTTest
  def test_empty
    line = LINE.new("", 0, nil)
    scanner = INLINE_SCANNER.new(line)
    assert scanner.empty?
  end

  def test_reading_when_empty
    line = LINE.new("1", 0, nil)
    scanner = INLINE_SCANNER.new(line)
    refute scanner.empty?
    char = scanner.read_next
    assert_equal line.content, char

    assert scanner.empty?
    assert_raises(ERRORS::InlineScannerIsEmpty) do
      scanner.read_next
    end
  end
end

class LineTest < NTTest
  def test_to_s
    content = "string content"
    line = LINE.new(content, 0, nil)
    repr = line.to_s
    assert repr.include? content
  end

  def test_invalid_tag
    line = LINE.new("", 0, nil)
    assert_raises(ERRORS::ParseLineTagUnknownError) do
      line.tag = :not_allowed
    end
  end
end
