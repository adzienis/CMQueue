module PolyScopedByParent
  extend ActiveSupport::Concern

  included do
    before_action :set_poly_scoped_by_parent
  end

  private

  def set_poly_scoped_by_parent
    resources = proc { instance_variable_get("@#{controller_name}") }
    set_resources = proc { |value| instance_variable_set("@#{controller_name}", value) }

    set_resources.call(resources.call.with_parent_type(params[:model_name])) if params[:model_name]
    set_resources.call(resources.call.with_parent_id(params[params[:model_name].foreign_key])) if params[:model_name]
  end
end
