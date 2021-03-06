# frozen_string_literal: true

require 'test_helper'

class NestedTextTest < NTTest
  def test_has_version
    refute_nil NestedText::VERSION
  end

  def test_has_version_semantic
    assert_match(/\d+\.\d+\.\d+/, NestedText::VERSION)
  end
end
