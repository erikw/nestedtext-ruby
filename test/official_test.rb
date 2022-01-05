require "test_helper"

require_relative "official_tests/api/nestedtext_official_tests"

class OfficialTest < Minitest::Test
  cases = NestedTextOfficialTests.load_test_cases
  cases.each do |phone_number|
    define_method("test_#{phone_number}_has_7_characters") do
      assert_equal(7, phone_number.length)
    end
  end
end
