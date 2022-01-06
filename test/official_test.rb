require "test_helper"

require_relative "official_tests/api/nestedtext_official_tests"

class OfficialTest < Minitest::Test
  cases = NestedTextOfficialTests.load_test_cases
  # TODO: define tests for: load_error, dump_success, dump_error

  NestedTextOfficialTests.select_load_success(cases).each do |caze|
    define_method("test_load_success_#{caze.name}") do
      actual = NestedText.load_file(caze[:load][:in][:path])
      expected = caze[:load][:out][:data]
      assert_equal(expected, actual)
    end
  end
end
