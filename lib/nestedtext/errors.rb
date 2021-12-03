# frozen_string_literal: true

module NestedText
  module Errors
    class MissingTermDefinition < StandardError
      def initialize(term_name) = super("NestedText entry for '#{term_name}' does not contain a definition!")
    end

    class MissingTermEntry < StandardError
      def initialize(term_name) = super("The term '#{term_name}' was not defined in the nestedtext")
    end

    class MultipleTermEntries < StandardError
      def initialize(term_name) = super("The term '#{term_name}' was defined multiple times in the nestedtext")
    end

    class NoNestedTextFile < StandardError; def initialize() = super("No data.nestedtext found") end

    class OptionsNoTermNameInTag < StandardError
      def initialize() = super("No term name argument for the nestedtext tag supplied")
    end

    class OptionsBadTagArgumentFormat < StandardError
      def initialize(term_name) = super("The nestedtext tag for term '#{term_name}' has a bad argument format")
    end

    class OptionsUnknownTagArgument < StandardError
      def initialize(arg) = super("An unknown tag argument #{arg} was encountered")
    end
  end
end
