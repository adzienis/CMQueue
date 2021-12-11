class ResourceGettable < Module
  def initialize(resource)
    super()
    resources = resource.to_s.underscore.pluralize
    resource_name = resource.to_s.underscore.singularize

    define_method(:resources) do
      instance_variable_get("@#{resources}")
    end
    define_method(:resource) do
      instance_variable_get("@#{resource_name}")
    end
    define_method(:resource_class) do
      resource.to_s.classify.constantize
    end
  end
end
