require "test_helper"

require_relative "official_tests/api/nestedtext_official_tests"

# class OfficialTest < Minitest::Test
class OfficialTest < Minitest::Unit::TestCase
  cases = NestedTextOfficialTests.load_test_cases
  # TODO: define tests for: load_error, dump_success, dump_error

  # Though in this case, it's nice to go though test cases in the same order as they have in the official suite.
  i_suck_and_my_tests_are_order_dependent!

  NestedTextOfficialTests.select_load_success(cases).each do |caze|
    define_method("test_load_success_#{caze.name}") do
      actual = NestedText.load_file(caze[:load][:in][:path])
      expected = caze[:load][:out][:data]
      assert_equal(expected, actual)
    end
  end
end
