require "test_helper"

class ErrorsInternalTest < NTTest
  def test_errors_no_instanciation
    assert_raises(NoMethodError) do
      NestedText::Error.new
    end
  end
end
