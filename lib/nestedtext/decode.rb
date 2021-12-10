# frozen_string_literal: true

require "nestedtext/parser"
require "nestedtext/errors"

require "logger"

module NestedText
  extend self # to make methods module public.

  def load(ntstring, top: Object)
    # logger = Logger.new(STDOUT) # TODO: make this available to other classes in module. How avoid singleton?
    # logger.info "input=#{raw_input_string}"
    # logger.info "top=#{top}"

    raise Errors::WrongInputTypeError, ntstring unless ntstring.nil? || ntstring.is_a?(String)

    unless !top.nil? && TOP_LEVEL_TYPES.map(&:object_id).include?(top.object_id)
      raise Errors::UnsupportedTopLevelTypeError, top
    end

    parser = Parser.new(ntstring, top)
    parser.parse
  end

  # TODO: def load_file() like YAML.load_file
end
