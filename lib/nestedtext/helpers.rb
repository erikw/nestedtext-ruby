module NestedText
  def self.assert_valid_top_level_type(top_class)
    unless !top_class.nil? && top_class.is_a?(Class) && TOP_LEVEL_TYPES.map(&:object_id).include?(top_class.object_id)
      raise Errors::UnsupportedTopLevelTypeError, top_class
    end
  end
end
