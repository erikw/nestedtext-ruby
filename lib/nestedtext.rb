# frozen_string_literal: true

require_relative 'nestedtext/core_ext'
require_relative 'nestedtext/decode'
require_relative 'nestedtext/encode'
require_relative 'nestedtext/encode_helpers'
require_relative 'nestedtext/error'
require_relative 'nestedtext/version'

# # NestedText
# A ruby library for the human friendly data format NestedText (https://nestedtext.org/).
#
# Provided is support for decoding a NestedText file or string to Ruby data structures,
# as well as encoding Ruby objects to a NestedText file or string. Furthermore there is
# support for serialization and deserialization of custom classes.
#
# See {file:README.md} for documentation on Types, Strict Mode and Custom Classes.
module NestedText
end
