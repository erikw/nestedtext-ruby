# frozen_string_literal: true

require "nestedtext/parser"
require "logger"

module NestedText
  extend self # to make methods module public.

  def load(input, top: Object)
    # logger = Logger.new(STDOUT) # TODO: make this available to other classes in module. How avoid singleton?
    # logger.info "input=#{raw_input_string}"
    # logger.info "top=#{top}"

    # TODO: assert input is of IO or StringIO
    # TODO: assert type of top is Class
    parser = Parser.new(input, top)
    parser.parse
  end
end
