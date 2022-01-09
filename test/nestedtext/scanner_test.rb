require "stringio"

require "test_helper"

class ScannerTest < Minitest::Test
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
