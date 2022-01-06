require "test_helper"

require_relative "official_tests/api/nestedtext_official_tests"

# Separate command name from internal tests, so that SimpleCov can distinguish and merge the total coverage.
# TODO does it beak codeclimate by not having this under test:bdd?
# TODO if test:bdd not needed, rename other test suite command_name to "test:internal"
# SimpleCov.command_name "test:integration"
SimpleCov.command_name "test:official"

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
