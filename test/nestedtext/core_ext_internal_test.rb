require "test_helper"
require "nestedtext/core_ext_internal"

class CoreExtInternalTest < NTTest
  using NestedText.const_get(:CoreExtInternal)

  def test_line_ending_crlf
    lines = "line1\r\nline2\r\n"
    exp = "line1\nline2\n"
    assert_equal exp, lines.normalize_line_endings
  end

  def test_line_ending_cr
    lines = "line1\rline2\r"
    exp = "line1\nline2\n"
    assert_equal exp, lines.normalize_line_endings
  end

  def test_line_ending_lf
    lines = "line1\nline2\n"
    assert_equal lines, lines.normalize_line_endings
  end

  def test_line_ending_crlf_trailing
    lines = "line1\r\nline2\r\n\r\n"
    exp = "line1\nline2\n\n"
    assert_equal exp, lines.normalize_line_endings
  end

  def test_line_ending_crlf_no_trailing
    lines = "line1\r\nline2"
    exp = "line1\nline2"
    assert_equal exp, lines.normalize_line_endings
  end
end
