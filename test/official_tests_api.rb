# frozen_string_literal: true

require 'json'

##
# An API for the offical NestedText test suite.
#
# This API is analogous to the official Python API
# https://github.com/KenKundert/nestedtext_tests/blob/master/api/nestedtext_official_tests.py
#
# How this API can be used can be seen in official_test.rb in the same directory as this file.
#
# This API assumes that the official test cases exist in a path relative to the script at
# ./official_tests/
module NestedTextOfficialTests
  def self.load_test_cases
    script_dir = File.expand_path("#{File.dirname(__FILE__)}/")
    puts script_dir
    cases_dir = "#{script_dir}/official_tests/test_cases"

    cases = []
    Dir.each_child(cases_dir) do |case_dir|
      cases << TestCase.new(case_dir, "#{cases_dir}/#{case_dir}")
    end

    cases
  end

  def self.select_load_success(cases)
    cases.select(&:load_success?)
  end

  def self.select_load_error(cases)
    cases.select(&:load_error?)
  end

  def self.select_dump_success(cases)
    cases.select(&:dump_success?)
  end

  def self.select_dump_error(cases)
    cases.select(&:dump_error?)
  end

  class TestCase
    attr_reader :name, :path

    def initialize(name, path)
      super()
      @name = name
      @path = path
      @case = {}

      @load_in =  "#{@path}/load_in.nt"
      @load_out = "#{@path}/load_out.json"
      @load_err = "#{@path}/load_err.json"
      @dump_in_json = "#{@path}/dump_in.json"
      @dump_in_ruby = "#{@path}/dump_in.rb"
      @dump_out = "#{@path}/dump_out.nt"
      @dump_err = "#{@path}/dump_err.json"

      read_load_files
      read_dump_files
    end

    def load_success?
      !@case&.[](:load)&.[](:out).nil?
    end

    def load_error?
      !@case&.[](:load)&.[](:err).nil?
    end

    def dump_success?
      !@case&.[](:dump)&.[](:out).nil?
    end

    def dump_error?
      !@case&.[](:dump)&.[](:err).nil?
    end

    def [](key)
      @case[key]
    end

    def self.load_ruby_file(file)
      require_relative file.delete_suffix('.rb')
      DATA
    end

    private

    def read_load_files
      return unless File.exist?(@load_in)

      @case[:load] = { in: { path: @load_in } }

      if File.exist?(@load_out) && File.exist?(@load_err)
        raise 'For a load_in.nt case, only one of load_out.json and load_err.json can exist!'
      end

      if File.exist?(@load_out)
        @case[:load][:out] = { path: @load_out, data: JSON.load_file(@load_out) }
      elsif File.exist?(@load_err)
        @case[:load][:err] = { path: @load_out, data: JSON.load_file(@load_err) }
      else
        raise 'For a load_in.nt case, one of load_out.json and load_err.json must exist!'
      end
    end

    def read_dump_in_files
      if File.exist?(@dump_in_json) && File.exist?(@dump_in_ruby)
        raise 'For a dump case, only one of the input files dump_in.json and dump_in.rb can exist!'
      end

      @case[:dump] = if File.exist?(@dump_in_json)
                       { in: { path: @dump_in_json, data: JSON.load_file(@dump_in_json) } }
                     else
                       { in: { path: @dump_in_ruby, data: TestCase.load_ruby_file(@dump_in_ruby) } }
                     end
    end

    def read_dump_out_err_files
      if File.exist?(@dump_out) && File.exist?(@dump_err)
        raise 'For a dump_in.json case, only one of dump_out.nt and dump_err.json can exist!'
      end

      if File.exist?(@dump_out)
        @case[:dump][:out] = { path: @dump_out, data: File.read(@dump_out) }
      elsif File.exist?(@dump_err)
        @case[:dump][:err] = { path: @dump_out, data: JSON.load_file(@dump_err) }
      else
        raise 'For a dump_in.json case, one of dump_out.json and dump_err.json must exist!'
      end
    end

    def read_dump_files
      return unless File.exist?(@dump_in_json) || File.exist?(@dump_in_ruby)

      read_dump_in_files
      read_dump_out_err_files
    end
  end
end
