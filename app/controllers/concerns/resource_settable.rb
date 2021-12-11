class ResourceSettable < Module
  def initialize(resource)
    resources = resource.to_s.underscore.pluralize
    resource_name = resource.to_s.underscore.singularize

    define_method(:set_resources) do |value|
      instance_variable_set("@#{resources}", value)
    end

    define_method(:set_resource) do |value|
      instance_variable_set("@#{resource_name}", value)
    end
  end
end
