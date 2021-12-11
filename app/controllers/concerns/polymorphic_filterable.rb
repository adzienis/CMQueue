module PolymorphicFilterable
  extend ActiveSupport::Concern

  included do
    before_action :set_polymorphic_filtered
  end

  private

  def set_polymorphic_filtered
    resources = proc { instance_variable_get("@#{controller_name}") }
    set_resources = proc { |value| instance_variable_set("@#{controller_name}", value) }

    set_resources.call(resources.call.with_type(params[:type])) if params[:type]
    set_resources.call(resources.call.where(resource_id: params[:id])) if params[:id]
  end
end
