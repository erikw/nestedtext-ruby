# frozen_string_literal: true

require 'test_helper'

require 'stringio'

class EncodeTest < NTTest
  def test_nil_strict
    assert_equal '', NestedText.dump(nil, strict: true)
  end

  def test_cyclic_references_no_cycle
    a = []
    b = [a, a]
    NestedText.dump(b)
  end

  def test_cyclic_references_simple
    a = []
    b = [a]
    a << b
    assert_raises(ERRORS::DumpCyclicReferencesDetectedError) do
      NestedText.dump(a)
    end
  end

  def test_cyclic_references_longer
    a = []
    b = ['i1', [a]]
    a << b
    assert_raises(ERRORS::DumpCyclicReferencesDetectedError) do
      NestedText.dump(a)
    end
  end
end

class EncodeArrayTest < NTTest # rubocop:disable Metrics/ClassLength
  def test_array_empty
    assert_equal '[]', NestedText.dump([])
  end

  def test_array_nil
    assert_equal '-', NestedText.dump([nil], strict: true)
  end

  def test_array_empty_string
    assert_equal '-', NestedText.dump([''])
  end

  def test_array_whitespace_string
    assert_equal '-  ', NestedText.dump([' '])
  end

  def test_array_one
    obj = ['an item here']
    exp = <<~NT.chomp
      - an item here
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_two_strings
    obj = %w[a b]
    exp = <<~NT.chomp
      - a
      - b
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_multiple_nil
    obj = [nil, 'a', nil]
    exp = <<~NT.chomp
      -
      - a
      -
    NT
    assert_equal exp, NestedText.dump(obj, strict: true)
  end

  def test_array_nested_array_first
    obj = [%w[a b], 'c']
    exp = <<~NT.chomp
      -
          - a
          - b
      - c
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_nested_array_last
    obj = ['a', %w[b c]]
    exp = <<~NT.chomp
      - a
      -
          - b
          - c
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_nested_array_middle
    obj = ['a', %w[b c], 'd']
    exp = <<~NT.chomp
      - a
      -
          - b
          - c
      - d
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_with_single_hash
    obj = [{ 'key' => 'value' }]
    exp = <<~NT.chomp
      -
          key: value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_with_multiple_hash
    obj = [
      { 'key1' => 'value1' },
      { "key2\nmultiline" => 'value2' },
      { 'key3' => "value3\nmultiline" }
    ]
    exp = <<~NT.chomp
      -
          key1: value1
      -
          : key2
          : multiline
              > value2
      -
          key3:
              > value3
              > multiline
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_array_with_symbols_strict
    obj = %i[sym1 sym2]
    assert_raises(ERRORS::DumpUnsupportedTypeError) do
      NestedText.dump(obj, strict: true)
    end
  end

  def test_array_with_symbols_non_strict
    obj = %i[sym1 sym2]
    exp = <<~NT.chomp
      - sym1
      - sym2
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_encode_non_standard_float_strict
    obj = [1.99]
    assert_raises(ERRORS::DumpUnsupportedTypeError) do
      NestedText.dump(obj, strict: true)
    end
  end

  def test_encode_non_standard_float_non_strict
    obj = [1.99]
    exp = '- 1.99'
    assert_equal exp, NestedText.dump(obj)
  end
end

class EncodeHashTest < NTTest  # rubocop:disable Metrics/ClassLength
  def test_hash_empty
    assert_equal '{}', NestedText.dump({})
  end

  def test_hash_single_nil_key
    obj = { nil => 'value' }
    exp = <<~NT.chomp
      :
          > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_nil_value
    obj = { 'key' => nil }
    exp = <<~NT.chomp
      key:
    NT
    assert_equal exp, NestedText.dump(obj, strict: true)
  end

  def test_hash_single_empty_value
    obj = { 'key' => '' }
    exp = <<~NT.chomp
      key:
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_whitespace_value
    obj = { 'key' => ' ' }
    exp = <<~NT.chomp
      key:#{'  '}
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_empty_key
    obj = { '' => 'value' }
    exp = <<~NT.chomp
      :
          > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_empty_key_and_value
    obj = { '' => '' }
    exp = <<~NT.chomp
      :
          >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_whitespace_key_and_value
    obj = { ' ' => ' ' }
    exp = <<~NT.chomp
      :#{'  '}
          >#{'  '}
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_single_item
    obj = { 'key' => 'value' }
    exp = <<~NT.chomp
      key: value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key
    obj = { "two line\n key" => 'value' }
    exp = <<~NT.chomp
      : two line
      :  key
          > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_lf_start
    obj = { "\nkey" => 'value' }
    exp = <<~NT.chomp
      :
      : key
          > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_lf_end
    obj = { "key\n" => 'value' }
    exp = <<~NT.chomp
      : key
      :
          > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_lf_end_double
    obj = { "key\n\n" => 'value' }
    exp = <<~NT.chomp
      : key
      :
      :
          > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_empty_value
    obj = { "k1\nk2" => '' }
    exp = <<~NT.chomp
      : k1
      : k2
          >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_whitespace_value
    obj = { "k1\nk2" => ' ' }
    exp = <<~NT.chomp
      : k1
      : k2
          >#{'  '}
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_many_lines
    obj = { "\na \n b\n\tc\n " => 'value' }
    exp = <<~NT.chomp
      :
      : a#{' '}
      :  b
      : \tc
      :#{'  '}
          > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_keys_multiline_values
    obj = {
      "k11\nk12" => "v11\nv12",
      "k21\nk22" => "v21\nv22"
    }
    exp = <<~NT.chomp
      : k11
      : k12
          > v11
          > v12
      : k21
      : k22
          > v21
          > v22
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_nested
    obj = { 'key1' => { 'key2' => 'value' } }
    exp = <<~NT.chomp
      key1:
          key2: value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_nested_multiline_value
    obj = { 'key1' => { 'key2' => "value\nhere" } }
    exp = <<~NT.chomp
      key1:
          key2:
              > value
              > here
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_nested_multiline_key_and_value
    obj = { "key\n1" => { "key\n2" => "value\nhere" } }
    exp = <<~NT.chomp
      : key
      : 1
          : key
          : 2
              > value
              > here
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_nested_empty_key
    obj = { 'key' => { '' => 'value' } }
    exp = <<~NT.chomp
      key:
          :
              > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_nested_empty_and_value
    obj = { 'key' => { '' => '' } }
    exp = <<~NT.chomp
      key:
          :
              >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_nested_whitespace_key
    obj = { 'key' => { ' ' => 'value' } }
    exp = <<~NT.chomp
      key:
          :#{'  '}
              > value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_nested_whitespace_key_and_value
    obj = { 'key' => { ' ' => ' ' } }
    exp = <<~NT.chomp
      key:
          :#{'  '}
              >#{'  '}
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_array_value
    obj = { 'key' => %w[i1 i2] }
    exp = <<~NT.chomp
      key:
          - i1
          - i2
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_key_tailing_colon_empty_value
    obj = { 'key:' => '' }
    exp = <<~NT.chomp
      key::
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_key_line_endings
    obj = {
      "key\r\n1" => 'cr/lf',
      "key\r2" => 'cr',
      "key\n3" => 'lf'
    }
    exp = <<~NT.chomp
      : key
      : 1
          > cr/lf
      : key
      : 2
          > cr
      : key
      : 3
          > lf
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_array_value
    obj = { "key\nline" => %w[i1 i2] }
    exp = <<~NT.chomp
      : key
      : line
          - i1
          - i2
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_multiline_string_value
    obj = { "key\nline" => "string\nline" }
    exp = <<~NT.chomp
      : key
      : line
          > string
          > line
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_multi_nesting
    obj = { "key\nline" => [%W[multiline\nstring item]] }
    exp = <<~NT.chomp
      : key
      : line
          -
              -
                  > multiline
                  > string
              - item
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_multiline_key_all_cases
    obj = {
      '' => 'empty key',
      "key\nline" => 'linefeed',
      ' ' => 'whitespace key',
      ' key' => 'leading whitespace',
      '[a, b]' => 'looks like inline list',
      '{a: b}' => 'looks like inline dict',
      ': key' => 'looks like multiline key',
      'key1: key2' => 'looks like multiline key',
      '#key' => 'looks like comment',
      '- key' => 'looks like list item',
      '> key' => 'looks like multiline string'
    }
    exp = <<~NT.chomp
      :
          > empty key
      : key
      : line
          > linefeed
      :#{'  '}
          > whitespace key
      :  key
          > leading whitespace
      : [a, b]
          > looks like inline list
      : {a: b}
          > looks like inline dict
      : : key
          > looks like multiline key
      : key1: key2
          > looks like multiline key
      : #key
          > looks like comment
      : - key
          > looks like list item
      : > key
          > looks like multiline string
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_symbol_key_strict
    obj = { key: 'value' }
    assert_raises(ERRORS::DumpHashKeyStrictStringError) do
      NestedText.dump(obj, strict: true)
    end
  end

  def test_hash_symbol_key_non_strict
    obj = { key: 'value' }
    exp = <<~NT.chomp
      key: value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_symbol_value_strict
    obj = { 'key' => :value }
    assert_raises(ERRORS::DumpUnsupportedTypeError) do
      NestedText.dump(obj, strict: true)
    end
  end

  def test_hash_symbol_value_non_strict
    obj = { 'key' => :value }
    exp = <<~NT.chomp
      key: value
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_int_value_strict
    obj = { 'key' => 1 }
    assert_raises(ERRORS::DumpUnsupportedTypeError) do
      NestedText.dump(obj, strict: true)
    end
  end

  def test_hash_int_value_non_strict
    obj = { 'key' => 1 }
    exp = <<~NT.chomp
      key: 1
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_hash_key_int_strict
    obj = { 1 => 'value' }
    assert_raises(ERRORS::DumpHashKeyStrictStringError) do
      NestedText.dump(obj, strict: true)
    end
  end

  def test_hash_key_int_non_strict
    obj = { 1 => 'value' }
    exp = <<~NT.chomp
      1: value
    NT
    assert_equal exp, NestedText.dump(obj)
  end
end

class EncodeStringTest < NTTest
  def test_string_empty
    assert_equal '>', NestedText.dump('')
  end

  def test_string_whitespace
    assert_equal '>  ', NestedText.dump(' ')
  end

  def test_string_simple
    obj = "  a string with\twords"
    exp = <<~NT.chomp
      > #{obj}
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_symbol_strict
    obj = :sym
    assert_raises(ERRORS::DumpUnsupportedTypeError) do
      NestedText.dump(obj, strict: true)
    end
  end

  def test_string_symbol_non_strict
    obj = :sym
    exp = <<~NT.chomp
      > sym
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_multiline
    obj = "  a string\t\n\twith multiple\nlines"
    exp = <<~NT.chomp
      >   a string\t
      > \twith multiple
      > lines
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_multiline_trailing_linefeed
    obj = "multi-line\nwith trailing line\n"
    exp = <<~NT.chomp
      > multi-line
      > with trailing line
      >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_multiline_multi_trailing_linefeed
    obj = "multi-line\nwith trailing line\n\t\n \n\n"
    exp = <<~NT.chomp
      > multi-line
      > with trailing line
      > \t
      >#{'  '}
      >
      >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_multiline_preceeding_linefeed
    obj = "\nempty line before and after\n"
    exp = <<~NT.chomp
      >
      > empty line before and after
      >
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_string_multiline_different_line_endings
    obj = "cr/lf\r\ncr\rlf\n"
    exp = <<~NT.chomp
      > cr/lf
      > cr
      > lf
      >
    NT
    assert_equal exp, NestedText.dump(obj)
  end
end

class EncodeInlineArrayTest < NTTest
  def test_inline_array_empty
    obj = []
    exp = <<~NT.chomp
      []
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_inline_array_simple
    obj = [[]]
    exp = <<~NT.chomp
      -
          []
    NT
    assert_equal exp, NestedText.dump(obj)
  end

  def test_inline_array_with_dict
    obj = [{}]
    exp = <<~NT.chomp
      -
          {}
    NT
    assert_equal exp, NestedText.dump(obj)
  end
end

class EncodeInlineHashTest < NTTest
  def test_inline_hash_empty
    obj = {}
    exp = <<~NT.chomp
      {}
    NT
    assert_equal exp, NestedText.dump(obj)
  end
end

class EncodeToIO < NTTest
  def setup
    @file = Tempfile.new('nestedtext_test')
  end

  def file_content
    File.read(@file)
  end

  def test_io_dump_file
    obj = %w[a b]
    exp = "- a\n- b"

    dumped = NestedText.dump_file(obj, @file.path)
    assert_equal exp, dumped
    assert_equal "#{exp}\n", file_content
  end

  def test_io_dump_io_param_file
    obj = %w[a b]
    exp = "- a\n- b"

    dumped = NestedText.dump(obj, io: @file)
    assert_equal exp, dumped
    assert_equal "#{exp}\n", file_content
  end

  def test_io_dump_io_param_stringio
    obj = %w[a b]
    exp = "- a\n- b"

    sio = StringIO.new
    dumped = NestedText.dump(obj, io: sio)
    assert_equal exp, dumped
    assert_equal "#{exp}\n", sio.string
  end

  def test_io_dump_invalid_io_array
    assert_raises(ERRORS::DumpBadIOError) do
      NestedText.dump('dummy', io: [])
    end
  end

  def test_io_dump_invalid_path_nil
    assert_raises(ERRORS::DumpFileBadPathError) do
      NestedText.dump_file('dummy', nil)
    end
  end
end
