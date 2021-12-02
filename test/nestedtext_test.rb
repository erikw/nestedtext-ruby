require "test_helper"

class NestedTextTest < Minitest::Test
  def test_success
    assert_equal 4, 4
  end

  def test_fail
    assert_equal 4, 5
  end
end
