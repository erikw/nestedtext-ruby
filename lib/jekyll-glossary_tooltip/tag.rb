# frozen_string_literal: true

require "jekyll"
require "nestedtext-ruby/errors"

module Jekyll
  module NestedText
    # Custom liquid tag implementation.
    class Tag < Liquid::Tag
      def initialize(tag_name, args, tokens)
        super
        @opts = OptionsParser.parse(args)
      end

      def render(context)
        entry = lookup_entry(context.registers[:site], @opts[:term_query])
        @opts[:display] ||= @opts[:term_query]
        <<~HTML
          <span class="jekyll-nestedtext">
             #{@opts[:display]}
             <span class="jekyll-nestedtext-tooltip">#{entry["definition"]}#{render_tooltip_url(entry)}</span>
          </span>
        HTML
      end

      private

      LOG_TAG = "NestedText Tag:"

      def render_tooltip_url(entry)
        # The content of the anchor is set from the CSS class jekyll-nestedtext-source-link,
        # so that the plugin user can customize the text without touching ruby source.
        anchor = "<br><a class=\"jekyll-nestedtext-source-link\" href=\"#{entry["url"]}\" target=\"_blank\"></a>"
        entry["url"] ? anchor : ""
      end

      def lookup_entry(site, term_name)
        entry = read_term_entry_from_config(site, term_name)
        raise Errors::MissingTermDefinition, term_name unless entry["definition"]

        entry["url"] = nil unless entry.key?("url")
        entry
      end

      # Retrieve a term from the nestedtext via the site.
      def read_term_entry_from_config(site, term_name)
        raise Errors::NoNestedTextFile unless site.data["nestedtext"]

        entries = site.data["nestedtext"].select do |entry|
          entry.key?("term") and term_name.casecmp(entry["term"]).zero?
        end

        case entries.length
        when 0
          raise Errors::MissingTermEntry, term_name
        when 1
          entries[0]
        else
          raise Errors::MultipleTermEntries, term_name
        end
      end
    end
  end
end

Liquid::Template.register_tag("nestedtext", Jekyll::NestedText::Tag)
