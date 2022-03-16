# frozen_string_literal: true

require 'test_helper'

class ErrorTest < NTTest
  def test_errors_no_instanciation
    assert_raises(NoMethodError) do
      NestedText::Error.new
    end
  end
end
