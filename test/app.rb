#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")
require('nestedtext')

raise 'Provide path to nestedtext file to parse as argument.' if ARGV.length != 1

pp NestedText.load_file(ARGV[0])
