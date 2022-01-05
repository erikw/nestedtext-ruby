require "test_helper"

require_relative "official_tests/api/nestedtext_official_tests"

class OfficialTest < Minitest::Test
  cases = NestedTextOfficialTests.load_test_cases
  # TODO: filter for load_success, load_error, dump_success & dump_error cases and indicate this in the method name # e.g.:
  # def test_load_success_dict_01
  # def test_dump_success_dict_01
  cases.each do |phone_number|
    define_method("test_#{phone_number}_has_7_characters") do
      assert_equal(7, phone_number.length)
    end
  end
end
