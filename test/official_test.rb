require "test_helper"

require_relative "official_tests/api/nestedtext_official_tests"

# Separate command name from internal tests, so that SimpleCov can distinguish and merge the total coverage.
# TODO does it beak codeclimate by not having this under test:bdd?
# TODO if test:bdd not needed, rename other test suite command_name to "test:internal"
# SimpleCov.command_name "test:integration"
SimpleCov.command_name "test:official"

# class OfficialTest < NTTest
class OfficialTest < Minitest::Test
  cases = NestedTextOfficialTests.load_test_cases
  # TODO: define tests for: dump_success, dump_error

  # Though in this case, it's nice to go though test cases in the same order as they have in the official suite.
  # TODO remove this after development and insteade use parallelize_me by extendint NTTest
  i_suck_and_my_tests_are_order_dependent!

  NestedTextOfficialTests.select_load_success(cases).each do |caze|
    define_method("test_load_success_#{caze.name}") do
      exp = caze[:load][:out][:data]
      act = NestedText.load_file(caze[:load][:in][:path])
      if exp.nil?
        assert_nil act
      else
        assert_equal(exp, act)
      end
    end
  end

  NestedTextOfficialTests.select_load_error(cases).each do |caze|
    define_method("test_load_error_#{caze.name}") do
      exp = caze[:load][:err][:data]

      begin
        NestedText.load_file(caze[:load][:in][:path])
      rescue NestedText::Errors::ParseError => e
        assert_equal(exp["lineno"], e.lineno, msg = "lineno is wrong")
        assert_equal(exp["colno"], e.colno, msg = "colno is wrong")
        assert_equal(exp["message"], e.message_raw, msg = "message is wrong")
      rescue Exception => e
        raise "Unexpected exception #{e.class.name} with message:\n#{e.message}\n, but expected one with with message:\n#{exp["message"]}\nBacktrace:\n#{e.backtrace.join("\n")}"
      else
        raise "No exception raised, but expected one with with message:\n#{exp["message"]}"
      end
    end
  end

  NestedTextOfficialTests.select_dump_success(cases).each do |caze|
    define_method("test_dump_success_#{caze.name}") do
      exp = caze[:dump][:out][:data].sub(/[\n\r]+$/, "")
      act = NestedText.dump(caze[:dump][:in][:data])
      if exp.nil?
        # TODO: this case needed?
        assert_nil act
      else
        assert_equal(exp, act)
      end
    end
  end
end
