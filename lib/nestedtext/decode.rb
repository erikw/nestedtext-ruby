# frozen_string_literal: true

require "nestedtext/parser"

module NestedText
  extend self  # to make methods module public.

  def load(raw_input_string)
    parser = Parser.new(raw_input_string)
    parser.parse
  end
end
