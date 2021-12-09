# frozen_string_literal: true

require "nestedtext/parser"
require "logger"

module NestedText
  extend self # to make methods module public.

  def load(raw_input_string, top: Object)
    # logger = Logger.new(STDOUT) # TODO: make this available to other classes in module. How avoid singleton?
    # logger.info "input=#{raw_input_string}"
    # logger.info "top=#{top}"

    # TODO: type of top is Class
    parser = Parser.new(raw_input_string, top)
    parser.parse
  end
end
