module NestedText
  # Hiding extensions for Kernel here away from users.
  # Reference: https://ruby-doc.org/core-3.1.0/doc/syntax/refinements_rdoc.html
  module CoreExtInternal
    refine String do
      def normalize_line_endings
        # Windows/Mac -> Unix
        gsub(/\r\n?/, "\n")
      end
    end
  end
  private_constant :CoreExtInternal
end
