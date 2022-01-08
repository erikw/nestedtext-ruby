#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../lib")
require("nestedtext")

raise "Provide path to nestedtext file to parse as argument." if ARGV.length != 1

ntfile = ARGV[0]

parsed = NestedText.load_file(ntfile)
pp parsed
