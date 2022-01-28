# frozen_string_literal: true

require "test_helper"
require "stringio"

class CoreExtTest < NTTest
  def test_to_nt_array
    obj = ["an item here"]
    exp = <<~NT.chomp
      - an item here
    NT
    assert_equal exp, obj.to_nt
  end

  def test_to_nt_hash
    obj = { "key" => "value" }
    exp = <<~NT.chomp
      key: value
    NT
    assert_equal exp, obj.to_nt
  end

  def test_to_nt_string
    obj = "multi-line\nstring"
    exp = <<~NT.chomp
      > multi-line
      > string
    NT
    assert_equal exp, obj.to_nt
  end

  def test_to_nt_io_param
    obj = %w[a b]
    exp = "- a\n- b"

    sio = StringIO.new
    dumped = obj.to_nt(io: sio)
    assert_equal exp, dumped
    assert_equal exp, sio.string
  end
end
