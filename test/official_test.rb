# frozen_string_literal: true

require 'test_helper'

require_relative 'official_tests/api/nestedtext_official_tests'

# Override - Separate command name from internal tests, so that SimpleCov can distinguish and merge the total coverage.
SimpleCov.command_name 'test:official'

class OfficialTest < Minitest::Test
  cases = NestedTextOfficialTests.load_test_cases

  NestedTextOfficialTests.select_load_success(cases).each do |caze|
    define_method("test_load_success_#{caze.name}") do
      act = NestedText.load_file(caze[:load][:in][:path], strict: true)
      exp = caze[:load][:out][:data]
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
        NestedText.load_file(caze[:load][:in][:path], strict: true)
      rescue ERRORS::ParseError => e
        assert_equal(exp['lineno'], e.lineno, 'lineno is wrong')
        assert_equal(exp['colno'], e.colno, 'colno is wrong')
        assert_equal(exp['message'], e.message_raw, 'message is wrong')
      rescue Exception => e
        raise "Unexpected exception #{e.class.name} with message:\n" \
          "#{e.message}\n, but expected one with with message:\n" \
          "#{exp['message']}\nBacktrace:\n#{e.backtrace.join("\n")}"
      else
        raise "No exception raised, but expected one with with message:\n#{exp['message']}"
      end
    end
  end

  NestedTextOfficialTests.select_dump_success(cases).each do |caze|
    define_method("test_dump_success_#{caze.name}") do
      act = NestedText.dump(caze[:dump][:in][:data], strict: true)
      exp = caze[:dump][:out][:data].sub(/[\n\r]+$/, '')
      assert_equal(exp, act)
    end
  end

  NestedTextOfficialTests.select_dump_error(cases).each do |caze|
    define_method("test_dump_error_#{caze.name}") do
      exp = caze[:dump][:err][:data]

      begin
        NestedText.dump(caze[:dump][:in][:data], strict: true)
      rescue ERRORS::DumpError => e
        assert_equal(exp['culprit'], e.culprit, 'culprit is wrong')
        assert_equal(exp['message'], e.message, 'message is wrong')
      rescue StandardError => e
        raise "Unexpected exception #{e.class.name} with message:\n" \
              "#{e.message}\n, but expected one with with message:\n" \
              "#{exp['message']}\nBacktrace:\n#{e.backtrace.join("\n")}"
      else
        raise "No exception raised, but expected one with with message:\n#{exp['message']}"
      end
    end
  end
end
