module NestedText
  def assert_valid_top_level_type(top)
    unless !top.nil? && top.is_a?(Class) && TOP_LEVEL_TYPES.map(&:object_id).include?(top.object_id)
      raise Errors::UnsupportedTopLevelTypeError, top
    end
  end
end
