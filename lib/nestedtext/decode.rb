# frozen_string_literal: true

require "nestedtext/parser"
require "nestedtext/errors"
require "nestedtext/helpers"

require "logger"
require "stringio"

module NestedText
  extend self # to make methods module public.

  def load(ntstring, top: Object)
    # logger = Logger.new(STDOUT) # TODO: make this available to other classes in module. How avoid singleton?
    # logger.info "input=#{raw_input_string}"
    # logger.info "top=#{top}"

    raise Errors::WrongInputTypeError.new([String], ntstring) unless ntstring.nil? || ntstring.is_a?(String)

    assert_valid_top_level_type top

    parser = Parser.new(StringIO.new(ntstring), top)
    parser.parse
  end

  # TODO: def load_file() like YAML.load_file
end
