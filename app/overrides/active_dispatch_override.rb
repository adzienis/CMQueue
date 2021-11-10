ActionDispatch::Routing::Mapper::Resources::Resource.class_eval do
  # force params to all look like #{resource}_id, even if they are not nested
  def nested_param
    :"#{singular}_id"
  end

  def member_scope
    "#{path}/:#{nested_param}"
  end
end