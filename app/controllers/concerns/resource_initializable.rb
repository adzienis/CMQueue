module ResourceInitializable
  extend ActiveSupport::Concern

  included do
    before_action :set_resource_initialized
  end

  private

  def set_resource_initialized

    resources = proc { instance_variable_get("@#{controller_name}") }
    set_resources = proc { |value| instance_variable_set("@#{controller_name}", value) }
    set_resource = proc { |value| instance_variable_set("@#{controller_name.singularize}", value) }

    set_resources.call(controller_path.camelize.classify.constantize.all)

    set_resource.call(resources.call.find(params[controller_name.singularize.foreign_key])) if params[controller_name.singularize.foreign_key]
  end
end