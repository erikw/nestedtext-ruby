# frozen_string_literal: true

require "nestedtext/errors"

module NestedText
  extend self  # to make methods module public.

  def load(_raw_input_string)
    {}
  end

  class Tag
    def initialize(tag_name, args, tokens); end
  end
end
