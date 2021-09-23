module ResourceAuthorizable
  extend ActiveSupport::Concern

  included do
    before_action :set_resource_authorized
  end

  private

  def set_resource_authorized
    resources = proc { instance_variable_get("@#{controller_name}") }
    set_resources = proc { |value| instance_variable_set("@#{controller_name}", value) }


    set_resources.call(resources.call.accessible_by(current_ability))
  end
end